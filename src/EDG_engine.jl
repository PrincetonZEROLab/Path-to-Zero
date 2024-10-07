function get_traces(df::DataFrame, week::Int, full_year::Bool, colors::Dict, is_WY_setup::Bool=false)
    start_hour = full_year ? 1 : (week - 1) * 24 * 7 + 1
    end_hour = (full_year ? 52 : week) * 24 * 7
    df_week = df[start_hour:end_hour, :]
    exclude = ["hour", "demand_gw", "battery_storage_level", "storage_level"]
    varnames = [name for name in names(df) if !(name in exclude)]
    lineattr = full_year ? [attr(width=1.5, color=colors[i]) for i in varnames] : [attr(width=2, color=colors[i]) for i in varnames]
    lineattr_dem = full_year ? attr(width=1, color="#101081") : attr(width=2, dash="dash", color="#101081")
    x_axis = full_year ? df[start_hour:end_hour, :hour] / (24 * 7) : (df[start_hour:end_hour, :hour] .- (df[start_hour, :hour] - 1)) / 24
    if is_WY_setup
        for i in eachindex(varnames)
            if varnames[i] == "Natural Gas"
                varnames[i] = "Existing Coal"
                colors["Existing Coal"] = colors["Natural Gas"]
                rename!(df, "Natural Gas" => "Existing Coal")
            elseif varnames[i] == "Nuclear"
                varnames[i] = "New Nuclear"
                colors["New Nuclear"] = colors["Nuclear"]
                rename!(df, "Nuclear" => "New Nuclear")
            end
        end
    end
    traces = [PlotlyBase.scatter(x=x_axis, y=df[start_hour:end_hour, variable], line=lineattr[i], mode="lines", stackgroup="one", name=variable) for (i, variable) in enumerate(varnames)]
    pushfirst!(traces, PlotlyBase.scatter(x=x_axis, y=df[start_hour:end_hour, :demand_gw], line=lineattr_dem, mode="lines", name="Demand"))
    return traces
end

function run_simulation(
    stage_num::Int64,
    planning_year::Int64,
    resource_params::Dict,
    scoring_params::Dict;
    path::String=".",
    is_new_nuclear::Bool=false
)

    stage_num = "Stage_" * string(stage_num)
    planning_year = string(planning_year)

    ## Load inputs
    in_path = (joinpath(path, "EDG_inputs", planning_year))

    (resources, G) = load_resources_input(in_path)

    # Update capacities to reflect capacity input
    for g in G
        resources.Existing_Cap_MW[resources.Resource.==names(resource_params["Start_Capacity"])[g]] =
            1000 * ([resource_params["Start_Capacity"][1, g] + resource_params["Build_Cost"][1, g] * resource_params["Build_Tokens"][1, g]])
    end

    # Battery energy capacity set to 4 hour duration (4:1 energy to power ratio)
    resources.Existing_Cap_MWh[resources.Resource.=="battery"] = resources.Existing_Cap_MW[resources.Resource.=="battery"] .* 4
    
    # Retire existing capacity if not maintained
    existing_resources = resources[resources.New_Build.==0, :]
    for res in existing_resources.Resource
        if res == "nuclear" && is_new_nuclear # If new nuclear, do not retire
            continue 
        elseif [1000 * resource_params["Build_Cost"][1, res] * resource_params["Build_Tokens"][1, res]] > resources.Existing_Cap_MW[resources.Resource.==res]
            resources.Existing_Cap_MW[resources.Resource.==res] = resources.Existing_Cap_MW[resources.Resource.==res]
        else
            resources.Existing_Cap_MW[resources.Resource.==res] = [1000 * resource_params["Build_Cost"][1, res] * resource_params["Build_Tokens"][1, res]]
        end
    end

    ending_capacity = DataFrame(Resource=resources.Resource, Ending_Cap_MW=resources.Existing_Cap_MW)

    @debug("SIMULATION STAGE")
    @debug("Existing capacity")
    @debug(ending_capacity)

    (demand, nse, sample_weight, hours_per_period, P, S, W, T) = load_demand_input(in_path)
    variability = load_variability_input(in_path)
    inputs = Dict(
        "G" => G,
        "S" => S,
        "T" => T,
        "resources" => resources,
        "demand" => demand,
        "nse" => nse,
        "sample_weight" => sample_weight,
        "hours_per_period" => hours_per_period,
        "variability" => variability)
    ##

    ## Solve model
    (model, solvetime) = solve(inputs)

    ## Record resource results,  dispatch results and score

    # Record generation capacity and energy results
    STOR = inputs["resources"].ID[inputs["resources"].STOR.>=1]
    generation = zeros(size(G, 1))
    for i in eachindex(G)
        # Note that total annual generation is sumproduct of sample period weights and hourly sample period generation 
        generation[i] = sum(sample_weight .* value.(model[:vGEN])[:, G[i]].data)
    end
    # For storage, it is a net consumer, so record net losses
    for s in STOR
        generation[s] =
            generation[s] - sum(sample_weight .* value.(model[:vCHARGE])[:, s].data)
    end

    ts_all_gen = vec(sum(value.(model[:vGEN][:, setdiff(G, STOR)]).data, dims=2))
    demand = inputs["demand"].Load_MW_z1
    reserve = ts_all_gen - demand
    min_reserve = minimum(reserve[reserve .> 0], init=0)

    total_generation = sum(generation[setdiff(G, STOR)]) # exclude storage from total generation
    
    # Total annual demand is sumproduct of sample period weights and hourly sample period demands
    total_demand = sum(sum.(eachcol(sample_weight .* inputs["demand"])))
    # Maximum aggregate demand is the maximum of the sum of total concurrent inputs["demand"] in each hour
    peak_demand = maximum(sum(eachcol(inputs["demand"])))
    MWh_share = generation ./ total_generation * 100
    cap_factor = (generation / 8760) ./ ending_capacity.Ending_Cap_MW * 100
    resource_results = DataFrame(
        ID=G,
        Resource=inputs["resources"].Resource[G],
        GWh=round.(generation / 1000),
        Percent_GWh=round.(MWh_share, digits=1),
        Ending_Capacity_GW=round.(ending_capacity.Ending_Cap_MW / 1000),
        Capacity_Factor=round.(cap_factor, digits=1)
    )

    # Record non-served energy results by segment and zone
    total_demand = sum(sum.(eachcol(sample_weight .* inputs["demand"])))
    num_segments = maximum(S)
    num_zones = 1
    nse_results = DataFrame(
        Max_NSE_GW=zeros(num_segments * num_zones),
        Total_NSE_GWh=zeros(num_segments * num_zones),
        NSE_Percent_of_Demand=zeros(num_segments * num_zones),
        Reliability=100.0,
        Reserve_Margin=min_reserve
    )
    i = 1
    for s in S
        nse_results.Max_NSE_GW[i] = maximum(value.(model[:vNSE])[:, s].data) / 1000
        nse_results.Total_NSE_GWh[i] = sum(sample_weight .* value.(model[:vNSE])[:, s].data) ./ 1000
        nse_results.NSE_Percent_of_Demand[i] = sum(sample_weight .* value.(model[:vNSE])[:, s].data) / total_demand * 100
        i = i + 1
    end
    nse_results.Reliability = [(1 - sum(nse_results.Total_NSE_GWh[:]) / (total_demand / 1000)) * 100]
    nse_results.Reliability = round.(nse_results.Reliability, digits=2)
    nse_results.NSE_Percent_of_Demand = round.(nse_results.NSE_Percent_of_Demand, digits=2)
    nse_results.Max_NSE_GW = round.(nse_results.Max_NSE_GW)
    nse_results.Total_NSE_GWh = round.(nse_results.Total_NSE_GWh)

    # Record hourly dispatch results
    dispatch_results = DataFrame(
        hour=T,
        demand_gw=round.(inputs["demand"].Load_MW_z1 ./ 1000, digits=1),
        battery_storage_level=round.(value.(model[:vSOC]).data[:] ./ 1000, digits=1),
        battery_charge=round.(value.(model[:vCHARGE]).data[:] ./ -1000, digits=1),
        demand_not_served=round.(value.(model[:vNSE])[:, 1].data ./ 1000, digits=1),
    )
    dispatch_results = hcat(dispatch_results, DataFrame(round.(value.(model[:vGEN]).data ./ 1000, digits=3), [Symbol(inputs["resources"].Resource[g]) for g in G]))

    # Scoring for round (reliability and clean energy shares)
    clean_share = round(100 - (sum(dispatch_results.natural_gas) / (sum(dispatch_results.demand_gw) - sum(dispatch_results.battery_charge))) * 100, digits=1)
    reliability = nse_results.Reliability[1]
    (reliability_score, clean_score) = calc_scores(stage_num, reliability, clean_share, scoring_params)
    scores = DataFrame(
        Reliability=reliability,
        Reliability_Points=reliability_score,
        Clean_Share=clean_share,
        Clean_Points=clean_score
    )

    return scores, dispatch_results, resource_results, nse_results
end

function load_resources_input(inputs_path::String)
    # resources (and storage) data:
    resources = CSV.read(joinpath(inputs_path, "Resources_data.csv"), DataFrame)
    # Read fuels data
    fuels = CSV.read(joinpath(inputs_path, "Fuels_data.csv"), DataFrame)

    # Many of the columns in the input data will be unused (this is input format for the GenX model)
    # Select the ones we want for this model
    resources = DataFrames.select(resources,
        :Resource, :Zone, :THERM, :STOR, :VRE, :New_Build,
        :Existing_Cap_MW, :Existing_Cap_MWh,
        :Var_OM_Cost_per_MWh, :Var_OM_Cost_per_MWh_In,
        :Heat_Rate_MMBTU_per_MWh, :Fuel,
        :Cap_Size, :Start_Cost_per_MW, :Start_Fuel_MMBTU_per_MW,
        :Up_Time, :Down_Time, :Min_Power,
        :Ramp_Up_Percentage, :Ramp_Dn_Percentage,
        :Eff_Up, :Eff_Down, :Resource_Type
    )
    resources.ID = 1:nrow(resources)
    # Set of all resources
    G = resources.ID

    # Calculate generator (and storage) total variable costs, start-up costs, 
    # and associated CO2 per MWh and per start
    resources.Var_Cost = zeros(Float64, size(G, 1))
    resources.CO2_Rate = zeros(Float64, size(G, 1))
    resources.Start_Cost = zeros(Float64, size(G, 1))
    resources.CO2_Per_Start = zeros(Float64, size(G, 1))
    for g in G
        # Variable cost ($/MWh) = variable O&M ($/MWh) + fuel cost ($/MMBtu) * heat rate (MMBtu/MWh)
        resources.Var_Cost[g] = resources.Var_OM_Cost_per_MWh[g] +
                                fuels[fuels.Fuel.==resources.Fuel[g], :Cost][1] * resources.Heat_Rate_MMBTU_per_MWh[g]
        # CO2 emissions rate (tCO2/MWh) = fuel CO2 content (tCO2/MMBtu) * heat rate (MMBtu/MWh)
        resources.CO2_Rate[g] = fuels[fuels.Fuel.==resources.Fuel[g], :Emissions][1] * resources.Heat_Rate_MMBTU_per_MWh[g]
        # Start-up cost ($/start/MW) = start up O&M cost ($/start/MW) + fuel cost ($/MMBtu) * start up fuel use (MMBtu/start/MW) 
        resources.Start_Cost[g] = resources.Start_Cost_per_MW[g] +
                                  fuels[fuels.Fuel.==resources.Fuel[g], :Cost][1] * resources.Start_Fuel_MMBTU_per_MW[g]
        # Start-up CO2 emissions (tCO2/start/MW) = fuel CO2 content (tCO2/MMBtu) * start up fuel use (MMBtu/start/MW) 
        resources.CO2_Per_Start[g] = fuels[fuels.Fuel.==resources.Fuel[g], :Emissions][1] * resources.Start_Fuel_MMBTU_per_MW[g]
    end
    # Note: after this, we don't need the fuels Data Frame again...

    return (resources, G)
end

function load_demand_input(inputs_path::String)

    # Read demand input data and record parameters
    demand_inputs = CSV.read(joinpath(inputs_path, "Load_data.csv"), DataFrame)
    # Value of lost load (cost of involuntary non-served energy)
    VOLL = demand_inputs.Voll[1]
    # Set of price responsive demand (non-served energy) segments
    S = convert(Array{Int64}, collect(skipmissing(demand_inputs.Demand_Segment)))
    #NOTE:  collect(skipmising(input)) is needed here in several spots because the demand inputs are not 'square' (different column lengths)

    # Data frame for price responsive demand segments (nse)
    # NSE_Cost = opportunity cost per MWh of demand curtailment
    # NSE_Max = maximum % of demand that can be curtailed in each hour
    # Note that nse segment 1 = involuntary non-served energy (load shedding) at $9000/MWh
    # and segment 2 = one segment of voluntary price responsive demand at $600/MWh (up to 7.5% of demand)
    nse = DataFrame(Segment=S,
        NSE_Cost=VOLL .* collect(skipmissing(demand_inputs.Cost_of_Demand_Curtailment_per_MW)),
        NSE_Max=collect(skipmissing(demand_inputs.Max_Demand_Curtailment)))

    # Set of sequential hours per sub-period
    hours_per_period = convert(Int64, demand_inputs.Timesteps_per_Rep_Period[1])
    # Set of time sample sub-periods (e.g. sample days or weeks)
    P = convert(Array{Int64}, 1:demand_inputs.Rep_Periods[1])
    # Sub period cluster weights = number of periods (days/weeks) represented by each sample period
    W = convert(Array{Int64}, collect(skipmissing(demand_inputs.Sub_Weights)))
    # Set of all time steps
    T = convert(Array{Int64}, demand_inputs.Time_Index)
    # Create vector of sample weights, representing how many hours in the year
    # each hour in each sample period represents
    sample_weight = zeros(Float64, size(T, 1))
    t = 1
    for p in P
        for h in 1:hours_per_period
            sample_weight[t] = W[p] / hours_per_period
            t = t + 1
        end
    end

    # Load/demand time series by zone (TxZ array)
    demand = DataFrames.select(demand_inputs, :Load_MW_z1)
    # Uncomment this line to explore the data if you wish:
    # show(demand, allrows=true, allcols=true)

    return (demand, nse, sample_weight, hours_per_period, P, S, W, T)
end

function load_variability_input(inputs_path::String)

    # Read resource capacity factors by hour (used for variable renewables)
    # There is one column here for each resource (row) in the resources DataFrame
    variability = CSV.read(joinpath(inputs_path, "Resources_variability.csv"), DataFrame)
    # Drop the first column with row indexes, as these are unecessary
    variability = variability[:, 2:ncol(variability)]
    # Ensure all columns are stored as Float64
    variability = convert.(Float64, variability[!, :])

    return variability
end


function resolve_uncertainty(inputs::Dict, uncertainty_params::Dict, shaping_tokens::Dict)
    # Calculate random demand shock as % change in hourly forecasted demand 
    # drawn from normal distribution with mean 0 and standard deviation given by 'demand_variance' argument
    demand_shock = 1 + rand(Normal(0, uncertainty_params["Demand_Variance"]), 1)[1]
    # Adjust hourly demand by shock
    inputs["demand"] = round.(demand_shock .* inputs["demand"])

    # Determine if a climate disaster occurs
    disaster = rand(Bernoulli(uncertainty_params["Disaster_Probability"]), 1)[1]
    forced_outages = zeros(Int8, length(inputs["G"])) # Record which resources are on outage in this vector
    if disaster
        # Disaster occurs in a random week. During that week, each resource faces a chance of outage.
        # The base outage probability is 50% but is reduced by investments in resilience. Every point
        # of climate resilience reduces probability by 10%. If outage occurs for a given resource, 
        # the maximum available capacity for that resource is reduced by 15%. 
        # Default values can be over-written by changing function parameters.
        week = convert(Int32, round(rand(1)[1] * 52))
        timesteps = (24*7*week+1):(24*7*week+24*14)
        # If Shaping Token invested in Resilience then outage probability is halved
        if shaping_tokens["Resilience"] > 0
            outage_prob = uncertainty_params["Outage_Probability"] / 2
        else
            outage_prob = uncertainty_params["Outage_Probability"]
        end
        # Calculate which plants experience forced outages
        for res in inputs["resources"].Resource
            if rand(Bernoulli(outage_prob), 1)[1]
                inputs["variability"][timesteps, Symbol(res)] = (1 - uncertainty_params["Outage_Rate"]) .* inputs["variability"][timesteps, Symbol(res)]
                forced_outages[inputs["resources"].Resource.==res] .= 1
            end
        end
    else
        week = -1
    end

    uncertainty = Dict(
        "Demand_Shock" => demand_shock - 1,
        "Disaster" => disaster,
        "Outage_Week" => week + 1,
        "Outage_Rate" => uncertainty_params["Outage_Rate"],
        "Forced_Outages" => forced_outages,
        "Resources" => inputs["resources"].Resource
    )

    return (inputs, uncertainty)
end

function solve(inputs::Dict)
    # sets and constants for local use
    G = inputs["G"]
    S = inputs["S"]
    T = inputs["T"]
    sample_weight = inputs["sample_weight"]
    hours_per_period = inputs["hours_per_period"]

    #SUBSETS
    # By naming convention, all subsets are UPPERCASE

    # Subset of G of all thermal resources subject to unit commitment constraints
    UC = intersect(inputs["resources"].ID[inputs["resources"].THERM.==1], G)
    # Subset of G NOT subject to unit commitment constraints
    #ED = intersect(inputs["resources"].ID[inputs["resources"].THERM.==2], G)
    # Subset of G of all storage resources
    STOR = intersect(inputs["resources"].ID[inputs["resources"].STOR.>=1], G)
    # Subset of G of all variable renewable resources
    VRE = intersect(inputs["resources"].ID[inputs["resources"].VRE.==1], G)

    # LP model using HiGHS solver
    EDG_Sim = Model(HiGHS.Optimizer)

    # DECISION VARIABLES
    # By naming convention, all decision variables start with v and then are in UPPER_SNAKE_CASE

    # Operational decision variables
    @variables(EDG_Sim, begin
        vGEN[T, g in G] >= inputs["resources"].Min_Power[g] * inputs["resources"].Existing_Cap_MW[g]  # Power generation (MW)
        vCHARGE[T, STOR] >= 0  # Power charging (MW)
        vSOC[T, STOR] >= 0  # Energy storage state of charge (MWh)
        vNSE[T, S] >= 0  # Non-served energy/demand curtailment (MW)
    end)

    # CONSTRAINTS
    # By naming convention, all constraints start with c and then are TitleCase

    # (1) Supply-demand balance constraint for all time steps
    @constraint(EDG_Sim, cDemandBalance[t in T],
        sum(vGEN[t, g] for g in G) +
        sum(vNSE[t, s] for s in S) -
        sum(vCHARGE[t, g] for g in STOR) -
        inputs["demand"][t, 1] == 0
    )

    # (2-6) Capacitated constraints:
    @constraints(EDG_Sim, begin
        # (2) Max power constraints for all time steps and all resources/storage
        cMaxPower[t in T, g in G], vGEN[t, g] <= inputs["variability"][t, g] * inputs["resources"].Existing_Cap_MW[g]
        # (3) Max charge constraints for all time steps and all storage resources
        cMaxCharge[t in T, g in STOR], vCHARGE[t, g] <= inputs["resources"].Existing_Cap_MW[g]
        # (4) Max state of charge constraints for all time steps and all storage resources
        cMaxSOC[t in T, g in STOR], vSOC[t, g] <= inputs["resources"].Existing_Cap_MWh[g]
        # (5) Max non-served energy constraints for all time steps and all segments
        cMaxNSE[t in T, s in S], vNSE[t, s] <= inputs["nse"].NSE_Max[s] * inputs["demand"][t, 1]
    end)

    # Because we are using time domain reduction via sample periods (days or weeks),
    # we must be careful with time coupling constraints at the start and end of each
    # sample period. 

    # First we record a subset of time steps that begin a sub period 
    # (these will be subject to 'wrapping' constraints that link the start/end of each period)
    # We include some additional logic for the case of 52 weeks because the full 8760 does not line up exactly
    # with 52 weeks. There is one extra day. This logic ignores the last "start".
    STARTS = convert(Array{Int64}, 1:hours_per_period:floor(maximum(T) / hours_per_period)*hours_per_period)
    # Then we record all time periods that do not begin a sub period 
    # (these will be subject to normal time couping constraints, looking back one period)
    INTERIORS = setdiff(T, STARTS)

    # (10-12) Time coupling constraints
    @constraints(EDG_Sim, begin
        # (10a) Ramp up constraints, normal
        cRampUp[t in INTERIORS, g in G],
        vGEN[t, g] - vGEN[t-1, g] <= inputs["resources"].Ramp_Up_Percentage[g] * inputs["resources"].Existing_Cap_MW[g]
        # (10b) Ramp up constraints, sub-period wrapping
        cRampUpWrap[t in STARTS, g in G],
        vGEN[t, g] - vGEN[t+hours_per_period-1, g] <= inputs["resources"].Ramp_Up_Percentage[g] * inputs["resources"].Existing_Cap_MW[g]

        # (11a) Ramp down, normal
        cRampDown[t in INTERIORS, g in G],
        vGEN[t-1, g] - vGEN[t, g] <= inputs["resources"].Ramp_Dn_Percentage[g] * inputs["resources"].Existing_Cap_MW[g]
        # (11b) Ramp down, sub-period wrapping
        cRampDownWrap[t in STARTS, g in G],
        vGEN[t+hours_per_period-1, g] - vGEN[t, g] <= inputs["resources"].Ramp_Dn_Percentage[g] * inputs["resources"].Existing_Cap_MW[g]

        # (12a) Storage state of charge, normal
        cSOC[t in INTERIORS, g in STOR],
        vSOC[t, g] == vSOC[t-1, g] + inputs["resources"].Eff_Up[g] * vCHARGE[t, g] - vGEN[t, g] / inputs["resources"].Eff_Down[g]
        # (12a) Storage state of charge, wrapping
        cSOCWrap[t in STARTS, g in STOR],
        vSOC[t, g] == vSOC[t+hours_per_period-1, g] + inputs["resources"].Eff_Up[g] * vCHARGE[t, g] - vGEN[t, g] / inputs["resources"].Eff_Down[g]
    end)

    # Create expressions for each sub-component of the total cost (for later retrieval)
    @expression(EDG_Sim, eVariableCosts,
        # Variable costs for generation, weighted by hourly sample weight
        sum(sample_weight[t] * inputs["resources"].Var_Cost[g] * vGEN[t, g] for t in T, g in G)
    )
    @expression(EDG_Sim, eNSECosts,
        # Non-served energy costs
        sum(sample_weight[t] * inputs["nse"].NSE_Cost[s] * vNSE[t, s] for t in T, s in S)
    )

    @expression(EDG_Sim, eTotalCosts,
        eVariableCosts + eNSECosts
    )

    @objective(EDG_Sim, Min,
        eTotalCosts
    )

    #     optimize!(EDG_Sim)
    set_silent(EDG_Sim)
    time = @elapsed optimize!(EDG_Sim)

    @debug("Objective value: ", objective_value(EDG_Sim))

    return (EDG_Sim, time)
end

function calc_scores(stage_num::String, reliability::Float64, clean_share::Float64, scoring_params::Dict)
    reliability_score = scoring_params["Max_Points"]
    for i in 1:scoring_params["Max_Points"]
        if reliability >= scoring_params["Reliability"][i]
            break
        else
            reliability_score = reliability_score - 1
        end
    end
    clean_score = scoring_params["Max_Points"]
    year = "Clean_" * stage_num
    for i in 1:scoring_params["Max_Points"]
        if clean_share >= scoring_params[year][i]
            break
        else
            clean_score = clean_score - 1
        end
    end
    return (reliability_score, clean_score)
end

function update_step(
    resource_params::Dict,
    shaping_tokens::Dict,
    experience_rate::Float64, # Experience rate is decline in technology cost for each build point spent on each resource
    backlash_risk::DataFrame,
    backlash_rates::DataFrame,
    is_new_nuclear::Bool=false
)

    G = size(resource_params["Build_Tokens"], 2)
    resources = names(resource_params["Build_Tokens"])

    ## Calculate social backlash for each resource 
    # using a Bernoulli distribution with one draw per Build token spent on each resource.
    # The backlash rate is halved by Shaping token invested in Social License.
    social_backlash = DataFrame(reshape(zeros(G), 1, G), names(resource_params["Build_Tokens"]))
    for g in 1:G
        resource = Symbol(resources[g])
        if shaping_tokens["Social_License"] > 0
            backlash_rate = backlash_rates[1, Symbol(backlash_risk[1, resource])] / 2
        else
            backlash_rate = backlash_rates[1, Symbol(backlash_risk[1, resource])]
        end
        draws = resource_params["Build_Tokens"][1, resource]
        backlash = sum(rand(Bernoulli(backlash_rate), draws))
        if backlash > 0
            social_backlash[1, resource] = 1
        end
    end

    ## Calculate cost reductions from experience curves for each resource
    # Actual experience rate is random variable drawn from a normal distribution with mean
    # equal to the experience_rate parameter and standard deviation of 5%.
    # Mean experience rate is doubled if Shaping Token invested in Innovation: Experience
    experience_results = DataFrame(reshape(zeros(G), 1, G), names(resource_params["Build_Tokens"]))
    for g in 1:G
        resource = Symbol(resources[g])
        if shaping_tokens["Innovation_Experience"] > 0
            experience = max(0.01, rand(Normal(experience_rate * 2, 0.05), 1)[1])
        else
            experience = max(0.01, rand(Normal(experience_rate, 0.05), 1)[1])
        end
        is_existing = resources[g] == "nuclear" || resources[g] == "natural_gas"
        is_existing_nuclear = resources[g] == "nuclear" && is_existing
        build_tokens = resource_params["Build_Tokens"][1, resource]
        if !(is_existing || build_tokens == 0) || (is_new_nuclear && is_existing_nuclear && build_tokens > 0)
            experience_results[1, resource] = round(experience, digits=3)
            resource_params["Build_Cost"][1, resource] =
                round(resource_params["Build_Cost"][1, resource] / (1 - experience)^resource_params["Build_Tokens"][1, resource])
        end
    end
    return social_backlash, resource_params["Build_Cost"], experience_results
end

function run_stage(
    stage_num::String,
    planning_year::String,
    resource_params::Dict,
    shaping_tokens::Dict,
    uncertainty_params::Dict,
    scoring_params::Dict,
    input_path::String,
    is_new_nuclear::Bool=false
)

    in_path = (joinpath(input_path, "EDG_inputs", planning_year))

    (resources, G) = load_resources_input(in_path)
    # Update capacities to reflect capacity input

    for res in names(resource_params["Start_Capacity"])
        resources.Existing_Cap_MW[resources.Resource.==res] =
            1000 * ([resource_params["Start_Capacity"][1, Symbol(res)] + resource_params["Build_Cost"][1, Symbol(res)] * resource_params["Build_Tokens"][1, Symbol(res)]])
    end

    # Battery energy capacity set to 4 hour duration (4:1 energy to power ratio)
    resources.Existing_Cap_MWh[resources.Resource.=="battery"] = resources.Existing_Cap_MW[resources.Resource.=="battery"] .* 4

    # Retire existing capacity if not maintained
    existing_resources = resources[resources.New_Build.==0, :]
    for res in existing_resources.Resource
        if res == "nuclear" && is_new_nuclear # Nuclear is maintained if is new nuclear
            continue
        elseif [1000 * resource_params["Build_Cost"][1, res] * resource_params["Build_Tokens"][1, res]] > resources.Existing_Cap_MW[resources.Resource.==res]
            resources.Existing_Cap_MW[resources.Resource.==res] = resources.Existing_Cap_MW[resources.Resource.==res]
        else
            resources.Existing_Cap_MW[resources.Resource.==res] = [1000 * resource_params["Build_Cost"][1, res] * resource_params["Build_Tokens"][1, res]]
        end
    end

    # Prevent clean firm capacity unless Innovation: Clean Firm shaping point is invested (and issue warning)
    if resources.Existing_Cap_MW[resources.Resource.=="clean_firm"][1] > 0 && shaping_tokens["Innovation_Clean_Firm"] == 0
        resources.Existing_Cap_MW[resources.Resource.=="clean_firm"][1] = 0
        @warn("WARNING: Clean Firm capacity not available.\nSpending Build Tokens spent on this capacity is dissalowed until Shaping Token invested in Innovation: Clean Firm")
    end

    ending_capacity = DataFrame(Resource=resources.Resource, Ending_Cap_MW=resources.Existing_Cap_MW)

    @debug("ADVANCE STAGE")
    @debug("Capacity")
    @debug(ending_capacity)

    (demand, nse, sample_weight, hours_per_period, P, S, W, T) = load_demand_input(in_path)
    variability = load_variability_input(in_path)
    inputs = Dict(
        "G" => G,
        "S" => S,
        "T" => T,
        "resources" => resources,
        "demand" => demand,
        "nse" => nse,
        "sample_weight" => sample_weight,
        "hours_per_period" => hours_per_period,
        "variability" => variability)

    (inputs, uncertainty) = resolve_uncertainty(inputs, uncertainty_params, shaping_tokens)

    (model, solvetime) = solve(inputs)

    resource_results, _, dispatch_results, uncertainty_results, scores = compute_results(inputs, model, solvetime, stage_num, uncertainty, ending_capacity, scoring_params)

    # Reformat ending capacity to return (to match format of resource_params)
    end_cap = DataFrame(reshape(zeros(size(G, 1)), 1, size(G, 1)), names(resource_params["Start_Capacity"]))
    for res in names(resource_params["Start_Capacity"])
        end_cap[1, Symbol(res)] = ending_capacity.Ending_Cap_MW[ending_capacity.Resource.==res][1]
    end
    return end_cap, resource_results, dispatch_results, uncertainty_results, scores
end

function advance_stage(
    stage_num::Int64,
    planning_year::Int64,
    resource_params::Dict,
    shaping_tokens::Dict,
    uncertainty_params::Dict,
    scoring_params::Dict,
    experience_rate::Float64,
    backlash_risk::DataFrame,
    backlash_rates::DataFrame;
    input_path::String=".",
    is_WY_setup::Bool=false,
    is_new_nuclear::Bool=false
)

    stage_num = "Stage_" * string(stage_num)
    planning_year = string(planning_year)

    resource_params["Start_Capacity"], resource_results, dispatch_results, uncertainty_results, scores = run_stage(stage_num, planning_year, resource_params, shaping_tokens, uncertainty_params, scoring_params,
        input_path, is_new_nuclear)
    social_backlash, resource_params["Build_Cost"], experience_results = update_step(resource_params, shaping_tokens, experience_rate, backlash_risk, backlash_rates, is_new_nuclear)

    # update resource parameters based on planning year
    if planning_year == "2030"
        if !is_WY_setup
            # Update resource parameters
            resource_params["Build_Cost"].nuclear[1] = ceil(resource_params["Build_Cost"].nuclear[1] / 2)
        end
        # Update uncertainty parameters
        uncertainty_params["Disaster_Probability"] = 0.5
    elseif planning_year == "2035"
        if !is_WY_setup
            # Update resource parameters
            resource_params["Build_Cost"].nuclear[1] = resource_params["Build_Cost"].nuclear[1] * 2
        end
        # Update uncertainty parameters
        uncertainty_params["Disaster_Probability"] = 0.9
    elseif planning_year == "2040"
    elseif planning_year == "2045"
    elseif planning_year == "2050"
    else
        throw(ArgumentError("Invalid planning year"))
    end

    return resource_params, dispatch_results, uncertainty_results, scores, social_backlash, experience_results
end


function compute_results(inputs::Dict,
    model::Model,
    time::Float64,
    stage_num::String,
    uncertainty::Dict,
    ending_capacity::DataFrame,
    scoring_params::Dict)


    # sets and constants for local use
    RES = inputs["resources"].Resource
    G = inputs["G"]
    S = inputs["S"]
    T = inputs["T"]
    sample_weight = inputs["sample_weight"]
    hours_per_period = inputs["hours_per_period"]
    STOR = inputs["resources"].ID[inputs["resources"].STOR.>=1]
    # Record generation capacity and energy results
    generation = zeros(size(G, 1))
    for g in G
        # Note that total annual generation is sumproduct of sample period weights and hourly sample period generation 
        generation[g] = sum(sample_weight .* value.(model[:vGEN])[:, g].data)
    end
    # For storage, it is a net consumer, so record net losses
    for s in STOR
        generation[s] =
            generation[s] - sum(sample_weight .* value.(model[:vCHARGE])[:, s].data)
    end
    total_generation = sum(generation[setdiff(G, STOR)]) # exclude storage from total generation

    # Total annual demand is sumproduct of sample period weights and hourly sample period demands
    total_demand = sum(sum.(eachcol(sample_weight .* inputs["demand"])))
    # Maximum aggregate demand is the maximum of the sum of total concurrent inputs["demand"] in each hour
    peak_demand = maximum(sum(eachcol(inputs["demand"])))
    MWh_share = generation ./ total_generation * 100
    cap_factor = (generation / 8760) ./ ending_capacity.Ending_Cap_MW * 100
    resource_results = DataFrame(
        ID=G,
        Resource=inputs["resources"].Resource[G],
        GWh=round.(generation / 1000),
        Percent_GWh=round.(MWh_share, digits=1),
        Ending_Capacity_GW=round.(ending_capacity.Ending_Cap_MW / 1000),
        Capacity_Factor=round.(cap_factor, digits=1)
    )

    ## Record non-served energy results by segment and zone
    num_segments = maximum(S)
    num_zones = 1
    nse_results = DataFrame(
        Segment=zeros(num_segments * num_zones),
        NSE_Price=zeros(num_segments * num_zones),
        Max_NSE_GW=zeros(num_segments * num_zones),
        Total_NSE_GWh=zeros(num_segments * num_zones),
        NSE_Percent_of_Demand=zeros(num_segments * num_zones),
        Reliability=100.0
    )
    i = 1
    for s in S
        nse_results.Segment[i] = s
        nse_results[!, :NSE_Price] .= inputs["nse"].NSE_Cost[s]
        nse_results.Max_NSE_GW[i] = maximum(value.(model[:vNSE])[:, s].data) / 1000
        nse_results.Total_NSE_GWh[i] = sum(sample_weight .* value.(model[:vNSE])[:, s].data) ./ 1000
        nse_results.NSE_Percent_of_Demand[i] = sum(sample_weight .* value.(model[:vNSE])[:, s].data) / total_demand * 100
        i = i + 1
    end
    nse_results.Reliability = [(1 - sum(nse_results.Total_NSE_GWh[:]) / (total_demand / 1000)) * 100]
    nse_results.Reliability = round.(nse_results.Reliability, digits=2)
    nse_results.NSE_Percent_of_Demand = round.(nse_results.NSE_Percent_of_Demand, digits=2)
    nse_results.Max_NSE_GW = round.(nse_results.Max_NSE_GW)
    nse_results.Total_NSE_GWh = round.(nse_results.Total_NSE_GWh)

    # Record hourly dispatch results
    dispatch_results = DataFrame(
        hour=T,
        demand_gw=round.(inputs["demand"].Load_MW_z1 ./ 1000, digits=1),
        storage_level=round.(value.(model[:vSOC]).data[:] ./ 1000, digits=1),
        storage_charge=round.(value.(model[:vCHARGE]).data[:] ./ -1000, digits=1),
        nonserved=round.(value.(model[:vNSE])[:, 1].data ./ 1000, digits=1),
    )
    dispatch_results = hcat(dispatch_results, DataFrame(round.(value.(model[:vGEN]).data ./ 1000, digits=3), [Symbol(inputs["resources"].Resource[g]) for g in G]))


    # Record costs by component (in million dollars)
    # Note: because each expression evaluates to a single value, 
    # value.(JuMPObject) returns a numerical value, not a DenseAxisArray;
    # We thus do not need to use the .data extension here to extract numeric values
    cost_results = DataFrame(
        Variable_Costs=round.(value.(model[:eVariableCosts]) / 10^6),
        NSE_Costs=round.(value.(model[:eNSECosts]) / 10^6),
        Total_Costs=round.(value.(model[:eTotalCosts]) / 10^6)
    )

    # Record reliability results
    uncertainty_results = DataFrame(
        Demand_Shock_Percent=round.(uncertainty["Demand_Shock"] * 100, digits=1),
        Disaster=uncertainty["Disaster"],
        Outage_Rate=uncertainty["Outage_Rate"],
        Outage_Week=uncertainty["Outage_Week"],
        Outage_NSE_Percent=0.0
    )
    if uncertainty["Disaster"]
        outage_range = (24*7*(uncertainty["Outage_Week"]-1)+1):(24*7*uncertainty["Outage_Week"])
        uncertainty_results.Outage_NSE_Percent[1] = round(sum(sample_weight[outage_range] .* value.(model[:vNSE])[outage_range, :].data) / total_demand * 100, digits=1)
    end
    uncertainty_results = hcat(uncertainty_results, DataFrame(reshape(uncertainty["Forced_Outages"], 1, length(G)), uncertainty["Resources"]))

    # Scoring for round (reliability and clean energy shares)
    clean_share = 100 - resource_results.Percent_GWh[resource_results.Resource.=="natural_gas"][1]
    reliability = nse_results.Reliability[1]
    (reliability_score, clean_score) = calc_scores(stage_num, reliability, clean_share, scoring_params)
    scores = DataFrame(
        Reliability=reliability,
        Reliability_Points=reliability_score,
        Clean_Share=clean_share,
        Clean_Points=clean_score
    )

    return resource_results, nse_results, dispatch_results, uncertainty_results, scores
end
