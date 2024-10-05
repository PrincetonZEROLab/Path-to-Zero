module App

using GenieFramework
using JuMP, CSV, Random, Distributions, YAML
using HiGHS
using DataFrames
using PlotlyBase

using ElectricityDecarbonizationGame

@genietools


@app begin

    ### UI setup
    # team setup
    @out team_path = ""
    @out team_name_not_set = true
    @out team_error_msg_style = ""
    @in team_name = ""
    @in team_name_confirmed = false

    # general variables
    @in game_over = false
    @in selected_file = "Select Setup File"

    # tabs
    @out tab = "Build"
    @in back_to_build_tab = false
    @out show_pannels = "display: "
    @out show_game_over = "display: none"

    # stages boxes
    @in label_year_1 = "NOW-2030"
    @in label_year_2 = "2031-2035"
    @in label_year_3 = "2036-2040"
    @in label_year_4 = "2041-2045"
    @in label_year_5 = "2046-2050"
    @out year = 0   # load from game setup. 0 is a default value
    @out _stages = [2030, 2035, 2040, 2045, 2050]
    @in color_year_1 = "background-color: rgb(16, 16, 129)"
    @in color_year_2 = "background-color: rgb(16, 16, 129)"
    @in color_year_3 = "background-color: rgb(16, 16, 129)"
    @in color_year_4 = "background-color: rgb(16, 16, 129)"
    @in color_year_5 = "background-color: rgb(16, 16, 129)"
    @in color_default = "background-color: rgb(16, 16, 129);"
    @in color_select = "background-color: rgb(255, 77, 31);"

    # stage scores
    @in stage_reliability = 0.0
    @in stage_reliability_points = 0.0
    @in stage_clean_share = 0.0
    @in stage_clean_points = 0.0

    # buttons to show tokens remaining
    @in available_budget_tokens = 5
    @out _current_stage_budget_tokens = 5
    @out available_shaping_tokens = 2
    @out _current_stage_shaping_tokens = 2
    @out _init_shaping_tokens = 2
    @out available_build_tokens = 10
    @out _available_build_tokens = [10, 10, 11, 11, 12]

    # scores variables
    @out reliability_score_stage_1 = 0
    @out reliability_score_stage_2 = 0
    @out reliability_score_stage_3 = 0
    @out reliability_score_stage_4 = 0
    @out reliability_score_stage_5 = 0
    @out clean_score_stage_1 = 0
    @out clean_score_stage_2 = 0
    @out clean_score_stage_3 = 0
    @out clean_score_stage_4 = 0
    @out clean_score_stage_5 = 0
    @out affordability_score = 25 # maximum score if all budget tokens are available
    @out total_score = 0

    # buttons to show budget tokens remaining
    @out bt_color_1 = "border: 1px solid black; background-color: rgb(160, 218, 170);"
    @out bt_color_2 = "border: 1px solid black; background-color: rgb(160, 218, 170);"
    @out bt_color_3 = "border: 1px solid black; background-color: rgb(160, 218, 170);"
    @out bt_color_4 = "border: 1px solid black; background-color: rgb(160, 218, 170);"
    @out bt_color_5 = "border: 1px solid black; background-color: rgb(160, 218, 170);"

    # buttons to buy build tokens
    @in bt_buy_build_token = false
    @in bt_undo_buy_build_token = false

    ## RESOURCE BLOCKS
    # Border color for each resource block
    @out b_color_resource_1 = ""
    @out b_color_resource_2 = ""
    @out b_color_resource_3 = ""
    @out b_color_resource_4 = ""
    @out b_color_resource_5 = ""
    @out b_color_resource_6 = ""
    @out b_color_resource_7 = ""
    @out b_color_resource_8 = ""

    # Resource names
    @out name_resource_1 = "UNKNOWN"
    @out name_resource_2 = "UNKNOWN"
    @out name_resource_3 = "UNKNOWN"
    @out name_resource_4 = "UNKNOWN"
    @out name_resource_5 = "UNKNOWN"
    @out name_resource_6 = "UNKNOWN"
    @out name_resource_7 = "UNKNOWN"
    @out name_resource_8 = "UNKNOWN"

    # Build button names
    @out bb_name_resource_1 = "Added capacity"
    @out bb_name_resource_2 = "Added capacity"
    @out bb_name_resource_3 = "Added capacity"
    @out bb_name_resource_4 = "Added capacity"
    @out bb_name_resource_5 = "Added capacity"
    @out bb_name_resource_6 = "Added capacity"
    @out bb_name_resource_7 = "Added capacity"
    @out bb_name_resource_8 = "Added capacity"

    # buttons to build capacity 
    @in resource_1_build_p = false
    @in resource_2_build_p = false
    @in resource_3_build_p = false
    @in resource_4_build_p = false
    @in resource_5_build_p = false
    @in resource_6_build_p = false
    @in resource_7_build_p = false
    @in resource_8_build_p = false

    @in resource_1_build_m = false
    @in resource_2_build_m = false
    @in resource_3_build_m = false
    @in resource_4_build_m = false
    @in resource_5_build_m = false
    @in resource_6_build_m = false
    @in resource_7_build_m = false
    @in resource_8_build_m = false

    # Build Capacity
    @in cap_resource_1_stage_1 = 0
    @in cap_resource_2_stage_1 = 0
    @in cap_resource_3_stage_1 = 0
    @in cap_resource_4_stage_1 = 0
    @in cap_resource_5_stage_1 = 0
    @in cap_resource_6_stage_1 = 0
    @in cap_resource_7_stage_1 = 0
    @in cap_resource_8_stage_1 = 0

    @in cap_resource_1_stage_2 = 0
    @in cap_resource_2_stage_2 = 0
    @in cap_resource_3_stage_2 = 0
    @in cap_resource_4_stage_2 = 0
    @in cap_resource_5_stage_2 = 0
    @in cap_resource_6_stage_2 = 0
    @in cap_resource_7_stage_2 = 0
    @in cap_resource_8_stage_2 = 0

    @in cap_resource_1_stage_3 = 0
    @in cap_resource_2_stage_3 = 0
    @in cap_resource_3_stage_3 = 0
    @in cap_resource_4_stage_3 = 0
    @in cap_resource_5_stage_3 = 0
    @in cap_resource_6_stage_3 = 0
    @in cap_resource_7_stage_3 = 0
    @in cap_resource_8_stage_3 = 0

    @in cap_resource_1_stage_4 = 0
    @in cap_resource_2_stage_4 = 0
    @in cap_resource_3_stage_4 = 0
    @in cap_resource_4_stage_4 = 0
    @in cap_resource_5_stage_4 = 0
    @in cap_resource_6_stage_4 = 0
    @in cap_resource_7_stage_4 = 0
    @in cap_resource_8_stage_4 = 0

    @in cap_resource_1_stage_5 = 0
    @in cap_resource_2_stage_5 = 0
    @in cap_resource_3_stage_5 = 0
    @in cap_resource_4_stage_5 = 0
    @in cap_resource_5_stage_5 = 0
    @in cap_resource_6_stage_5 = 0
    @in cap_resource_7_stage_5 = 0
    @in cap_resource_8_stage_5 = 0

    # Cumulative Capacity
    @out cum_cap_resource_1 = 0
    @out cum_cap_resource_2 = 0
    @out cum_cap_resource_3 = 0
    @out cum_cap_resource_4 = 0
    @out cum_cap_resource_5 = 0
    @out cum_cap_resource_6 = 0
    @out cum_cap_resource_7 = 0
    @out cum_cap_resource_8 = 0

    # Build Tokens
    @out bt_resource_1 = 0
    @out bt_resource_2 = 0
    @out bt_resource_3 = 0
    @out bt_resource_4 = 0
    @out bt_resource_5 = 0
    @out bt_resource_6 = 0
    @out bt_resource_7 = 0
    @out bt_resource_8 = 0

    # start capacity
    @in sc_resource_1 = 0
    @in sc_resource_2 = 0
    @in sc_resource_3 = 0
    @in sc_resource_4 = 0
    @in sc_resource_5 = 0
    @in sc_resource_6 = 0
    @in sc_resource_7 = 0
    @in sc_resource_8 = 0

    # build cost
    @in bc_resource_1 = 0
    @in bc_resource_2 = 0
    @in bc_resource_3 = 0
    @in bc_resource_4 = 0
    @in bc_resource_5 = 0
    @in bc_resource_6 = 0
    @in bc_resource_7 = 0
    @in bc_resource_8 = 0

    # is new resource flag 
    @out is_new_resource_1 = false
    @out is_new_resource_2 = false
    @out is_new_resource_3 = false
    @out is_new_resource_4 = false
    @out is_new_resource_5 = false
    @out is_new_resource_6 = false
    @out is_new_resource_7 = false
    @out is_new_resource_8 = false

    # is clean firm flag
    @out is_clean_firm_resource_1 = false
    @out is_clean_firm_resource_2 = false
    @out is_clean_firm_resource_3 = false
    @out is_clean_firm_resource_4 = false
    @out is_clean_firm_resource_5 = false
    @out is_clean_firm_resource_6 = false
    @out is_clean_firm_resource_7 = false
    @out is_clean_firm_resource_8 = false

    # social backlash parameters
    @in sbp_resource_1 = "none"
    @in sbp_resource_2 = "none"
    @in sbp_resource_3 = "none"
    @in sbp_resource_4 = "none"
    @in sbp_resource_5 = "none"
    @in sbp_resource_6 = "none"
    @in sbp_resource_7 = "none"
    @in sbp_resource_8 = "none"

    # new nuclear resource
    @out is_WY_setup = false
    @out nuclear_relicensed = "display: none"

    ## SHAPE THE FUTURE TAB
    # shaping tokens buttons
    @in bt_resilience = false
    @in bt_innovation_experience = false
    @in bt_innovation_clean_firm = false
    @in bt_social_license = false
    @in shaping_tokens_warning = "display:"
    # button to buy shaping tokens
    @in bt_buy_shaping_token = false
    @in bt_undo_buy_shaping_token = false
    # shaping tokens disabled
    @out bt_resilience_is_disabled = false
    @out bt_innovation_experience_is_disabled = false
    @out bt_innovation_clean_firm_is_disabled = false
    @out bt_social_license_is_disabled = false

    ## SIMULATION
    @in run_simulation = false
    # plotting simulation results
    @out plot_df = DataFrame()
    @in plot_full_year = true
    @in plot_week = 1
    @out plot_traces = [PlotlyBase.scatter(x=1:24*7, y=zeros(Float32, 24 * 7))]
    @out plot_layout = PlotlyBase.Layout(
        title="Simulation Results",
        Dict{Symbol,Any}(:paper_bgcolor => "rgb(242, 246, 247)", :plot_bgcolor => "rgb(242, 246, 247)");
        xaxis=attr(title="Week", showgrid=true, dtick=5),
        yaxis=attr(title="Usage", showgrid=true),
        legend=attr(x=1, y=1.02, yanchor="bottom", xanchor="right", orientation="h"),
        backgroundcolor="red",
    )

    # advance stage button
    @in confirm_advance_stage = false
    @in advance_stage = false

    ## STAGE RESULTS
    # disaster variables
    @out demand_shock_percent = 0.0
    @out outage_weeks = "None"

    @out disaster_occurred = "display: none"
    @out disaster_resource_1 = false
    @out disaster_resource_2 = false
    @out disaster_resource_3 = false
    @out disaster_resource_4 = false
    @out disaster_resource_5 = false
    @out disaster_resource_6 = false
    @out disaster_resource_7 = false
    @out disaster_resource_8 = false

    # social backlash variables
    @out social_backlash_resource_1 = false
    @out social_backlash_resource_2 = false
    @out social_backlash_resource_3 = false
    @out social_backlash_resource_4 = false
    @out social_backlash_resource_5 = false
    @out social_backlash_resource_6 = false
    @out social_backlash_resource_7 = false
    @out social_backlash_resource_8 = false
    @out bt_resource_1_disabled = ""
    @out bt_resource_2_disabled = ""
    @out bt_resource_3_disabled = ""
    @out bt_resource_4_disabled = ""
    @out bt_resource_5_disabled = ""
    @out bt_resource_6_disabled = ""
    @out bt_resource_7_disabled = ""
    @out bt_resource_8_disabled = ""

    ### BACKEND VARIABLES
    @in current_stage = 1 # index of the current stage

    # name for backend data
    @in backend_data_name_1 = "resource_1"
    @in backend_data_name_2 = "resource_2"
    @in backend_data_name_3 = "resource_3"
    @in backend_data_name_4 = "resource_4"
    @in backend_data_name_5 = "resource_5"
    @in backend_data_name_6 = "resource_6"
    @in backend_data_name_7 = "resource_7"
    @in backend_data_name_8 = "resource_8"

    # shaping tokens data structure
    @in shaping_tokens = Dict(
        "Resilience" => [0, false],
        "Innovation_Experience" => [0, false],
        "Innovation_Clean_Firm" => [0, false],
        "Social_License" => [0, false]
    )
    # value of the shaping tokens in the current stage
    @in resilience = false
    @in innovation_experience = false
    @in innovation_clean_firm = false
    @in social_license = false

    # uncertainty parameters
    @in up_demand_variance = 0.1
    @in up_disaster_probability = 0.1
    @in up_outage_probability = 0.66
    @in up_outage_rate = 0.5

    # experience rate
    @in experience_rate = 0.5

    # backlash rates
    @in br_none = 0
    @in br_low = 0.1
    @in br_moderate = 0.17
    @in br_high = 0.25

    # scoring setup
    @in sp_max_points = 5
    @in sp_clean_stage_1 = [60, 58, 56, 53, 50]
    @in sp_clean_stage_2 = [70, 68, 66, 63, 60]
    @in sp_clean_stage_3 = [80, 78, 76, 73, 70]
    @in sp_clean_stage_4 = [90, 88, 86, 83, 80]
    @in sp_clean_stage_5 = [99.9, 99, 98, 96, 90]
    @in sp_reliability = [99.9, 99.5, 99, 98, 97]

    ## SCORES VARIABLES in the current stage
    @in Reliability = 0.0
    @in Reliability_Points = 0.0
    @in Clean_Share = 0.0
    @in Clean_Points = 0.0

    ## PLOTTING
    # default colors for the plot
    const plot_colors = Dict(
        "Nuclear" => "#8c564b",
        "Natural Gas" => "#d62728",
        "Clean Firm" => "#17becf",
        "Solar PV (Utility Scale)" => "#EBC334",
        "Distributed Solar PV" => "#ff7f0e",
        "Onshore Wind" => "#2ca02c",
        "Offshore Wind" => "#1f77b4",
        "Battery Discharge" => "#e377c2",
        "Battery Charge" => "#9467bd",
        "Demand not served" => "#000000"
    )

    # plotting stage results
    @out plot_stage_results = DataFrame()
    @in plot_stage_full_year = true
    @in plot_stage_week = 1
    @out plot_stage_traces = [PlotlyBase.scatter(x=1:24*7, y=zeros(Float32, 24 * 7))]
    @out plot_stage_layout = PlotlyBase.Layout(
        title="",
        Dict{Symbol,Any}(:paper_bgcolor => "rgb(242, 246, 247)", :plot_bgcolor => "rgb(242, 246, 247)");
        xaxis=attr(title="Week", showgrid=true, dtick=5),
        yaxis=attr(title="Usage", showgrid=true),
        legend=attr(x=1, y=1.02, yanchor="bottom", xanchor="right", orientation="h"),
        backgroundcolor="red",
    )

    ### GAME LOGIC
    const FILE_PATH = joinpath("game_setup")
    mkpath(FILE_PATH)
    @out upfiles = readdir(FILE_PATH)
    # team name setup
    @onchange team_name_confirmed begin
        if !team_name_confirmed && team_name == ""
            team_name_error = "Please enter a team name"
        else
            team_error_msg_style = "display: none"
            team_name_not_set = false
            team_name_error = ""
            team_path = joinpath(FILE_PATH, team_name)
            isdir(team_path) || mkpath(team_path)
            for file in filter(x -> endswith(x, ".yml"), readdir(FILE_PATH))
                cp(joinpath(FILE_PATH, file), joinpath(team_path, file); force=true)
            end
            upfiles = readdir(team_path)
        end
    end
    # update setup file list 
    @onchange fileuploads begin
        if !isempty(fileuploads)
            @info "File was uploaded: " fileuploads
            filename = fileuploads["name"]
            try
                isdir(team_path) || mkpath(team_path)
                mv(fileuploads["path"], joinpath(team_path, filename), force=true)
            catch e
                @error "Error processing file: $e"
                notify(__model__, "Error processing file: $(fileuploads["name"])")
            end
            fileuploads = Dict{AbstractString,AbstractString}()
        end
        upfiles = readdir(team_path)
    end
    @event uploaded begin
        @info "uploaded"
        notify(__model__, "File was uploaded")
    end
    @event rejected begin
        @info "rejected"
        notify(__model__, "Please upload a valid file")
    end
    # load game setup from the file selected
    @onchange selected_file begin 
        _game_setup = YAML.load_file(joinpath(team_path, selected_file))

        current_stage = 1
        if haskey(_game_setup, "current_stage")
            current_stage = _game_setup["current_stage"]
        end

        if current_stage == 1
            _init_shaping_tokens = _game_setup["available_shaping_tokens"]
            is_WY_setup = selected_file == "WY_setup.yml" 
        end

        if current_stage == 2   # TODO: ask about this
            is_WY_setup = _game_setup["is_WY_setup"]
            if !is_WY_setup
                nuclear_relicensed = "display:"
            end
        else
            nuclear_relicensed = "display: none"
        end

        if current_stage == 6
            game_over = true
            show_game_over = "display: "
            current_stage = 5
        else
            game_over = false
            show_game_over = "display: none"
        end

        available_budget_tokens = _game_setup["available_budget_tokens"]
        _current_stage_budget_tokens = _game_setup["available_budget_tokens"]
        available_shaping_tokens = _game_setup["available_shaping_tokens"]
        _current_stage_shaping_tokens = _game_setup["current_stage_shaping_tokens"]
        _available_build_tokens = _game_setup["available_build_tokens"]
        available_build_tokens = _available_build_tokens[current_stage]
        
        _stages = _game_setup["stages"]
        @assert length(_stages) == 5

        year = _stages[current_stage]

        label_year_1 = "NOW-" * string(_stages[1])
        label_year_2 = string(_stages[1] + 1) * "-" * string(_stages[2])
        label_year_3 = string(_stages[2] + 1) * "-" * string(_stages[3])
        label_year_4 = string(_stages[3] + 1) * "-" * string(_stages[4])
        label_year_5 = string(_stages[4] + 1) * "-" * string(_stages[5])

        resource_blocks = _game_setup["resource_blocks"]

        block_1 = resource_blocks["block_1"]
        name_resource_1 = block_1["name"]
        sc_resource_1 = block_1["start_capacity"]
        bc_resource_1 = block_1["build_cost"]
        sbp_resource_1 = block_1["backlash_risk"]
        backend_data_name_1 = block_1["EDG_data_name"]
        is_new_resource_1 = block_1["new_resource"]
        name_resource_1 = is_new_resource_1 ? name_resource_1 : name_resource_1 * " (EXISTING)"
        cum_cap_resource_1 = sc_resource_1
        bb_name_resource_1 = is_new_resource_1 ? "Added capacity" : "Retained capacity"
        b_color_resource_1 = is_new_resource_1 ? "border: 2px solid rgb(16, 16, 129);" : "border: 2px solid rgb(255, 198, 151);"
        b_color_resource_1 *= backend_data_name_1 == "clean_firm" ? color_select : ""
        is_clean_firm_resource_1 = backend_data_name_1 == "clean_firm" ? true : false

        block_2 = resource_blocks["block_2"]
        name_resource_2 = block_2["name"]
        sc_resource_2 = block_2["start_capacity"]
        bc_resource_2 = block_2["build_cost"]
        sbp_resource_2 = block_2["backlash_risk"]
        backend_data_name_2 = block_2["EDG_data_name"]
        is_new_resource_2 = block_2["new_resource"]
        name_resource_2 = is_new_resource_2 ? name_resource_2 : name_resource_2 * " (EXISTING)"
        cum_cap_resource_2 = sc_resource_2
        bb_name_resource_2 = is_new_resource_2 ? "Added capacity" : "Retained capacity"
        b_color_resource_2 = is_new_resource_2 ? "border: 2px solid rgb(16, 16, 129);" : "border: 2px solid rgb(255, 198, 151);"
        b_color_resource_2 *= backend_data_name_2 == "clean_firm" ? color_select : ""
        is_clean_firm_resource_2 = backend_data_name_2 == "clean_firm" ? true : false

        block_3 = resource_blocks["block_3"]
        name_resource_3 = block_3["name"]
        sc_resource_3 = block_3["start_capacity"]
        bc_resource_3 = block_3["build_cost"]
        sbp_resource_3 = block_3["backlash_risk"]
        backend_data_name_3 = block_3["EDG_data_name"]
        is_new_resource_3 = block_3["new_resource"]
        name_resource_3 = is_new_resource_3 ? name_resource_3 : name_resource_3 * " (EXISTING)"
        cum_cap_resource_3 = sc_resource_3
        bb_name_resource_3 = is_new_resource_3 ? "Added capacity" : "Retained capacity"
        b_color_resource_3 = is_new_resource_3 ? "border: 2px solid rgb(16, 16, 129);" : "border: 2px solid rgb(255, 198, 151);"
        b_color_resource_3 *= backend_data_name_3 == "clean_firm" ? color_select : ""
        is_clean_firm_resource_3 = backend_data_name_3 == "clean_firm" ? true : false

        block_4 = resource_blocks["block_4"]
        name_resource_4 = block_4["name"]
        sc_resource_4 = block_4["start_capacity"]
        bc_resource_4 = block_4["build_cost"]
        sbp_resource_4 = block_4["backlash_risk"]
        backend_data_name_4 = block_4["EDG_data_name"]
        is_new_resource_4 = block_4["new_resource"]
        name_resource_4 = is_new_resource_4 ? name_resource_4 : name_resource_4 * " (EXISTING)"
        cum_cap_resource_4 = sc_resource_4
        bb_name_resource_4 = is_new_resource_4 ? "Added capacity" : "Retained capacity"
        b_color_resource_4 = is_new_resource_4 ? "border: 2px solid rgb(16, 16, 129);" : "border: 2px solid rgb(255, 198, 151);"
        b_color_resource_4 *= backend_data_name_4 == "clean_firm" ? color_select : ""
        is_clean_firm_resource_4 = backend_data_name_4 == "clean_firm" ? true : false

        block_5 = resource_blocks["block_5"]
        name_resource_5 = block_5["name"]
        sc_resource_5 = block_5["start_capacity"]
        bc_resource_5 = block_5["build_cost"]
        sbp_resource_5 = block_5["backlash_risk"]
        backend_data_name_5 = block_5["EDG_data_name"]
        is_new_resource_5 = block_5["new_resource"]
        name_resource_5 = is_new_resource_5 ? name_resource_5 : name_resource_5 * " (EXISTING)"
        cum_cap_resource_5 = sc_resource_5
        bb_name_resource_5 = is_new_resource_5 ? "Added capacity" : "Retained capacity"
        b_color_resource_5 = is_new_resource_5 ? "border: 2px solid rgb(16, 16, 129);" : "border: 2px solid rgb(255, 198, 151);"
        b_color_resource_5 *= backend_data_name_5 == "clean_firm" ? color_select : ""
        is_clean_firm_resource_5 = backend_data_name_5 == "clean_firm" ? true : false

        block_6 = resource_blocks["block_6"]
        name_resource_6 = block_6["name"]
        sc_resource_6 = block_6["start_capacity"]
        bc_resource_6 = block_6["build_cost"]
        sbp_resource_6 = block_6["backlash_risk"]
        backend_data_name_6 = block_6["EDG_data_name"]
        is_new_resource_6 = block_6["new_resource"]
        name_resource_6 = is_new_resource_6 ? name_resource_6 : name_resource_6 * " (EXISTING)"
        cum_cap_resource_6 = sc_resource_6
        bb_name_resource_6 = is_new_resource_6 ? "Added capacity" : "Retained capacity"
        b_color_resource_6 = is_new_resource_6 ? "border: 2px solid rgb(16, 16, 129);" : "border: 2px solid rgb(255, 198, 151);"
        b_color_resource_6 *= backend_data_name_6 == "clean_firm" ? color_select : ""
        is_clean_firm_resource_6 = backend_data_name_6 == "clean_firm" ? true : false

        block_7 = resource_blocks["block_7"]
        name_resource_7 = block_7["name"]
        sc_resource_7 = block_7["start_capacity"]
        bc_resource_7 = block_7["build_cost"]
        sbp_resource_7 = block_7["backlash_risk"]
        backend_data_name_7 = block_7["EDG_data_name"]
        is_new_resource_7 = block_7["new_resource"]
        name_resource_7 = is_new_resource_7 ? name_resource_7 : name_resource_7 * " (EXISTING)"
        cum_cap_resource_7 = sc_resource_7
        bb_name_resource_7 = is_new_resource_7 ? "Added capacity" : "Retained capacity"
        b_color_resource_7 = is_new_resource_7 ? "border: 2px solid rgb(16, 16, 129);" : "border: 2px solid rgb(255, 198, 151);"
        b_color_resource_7 *= backend_data_name_7 == "clean_firm" ? color_select : ""
        is_clean_firm_resource_7 = backend_data_name_7 == "clean_firm" ? true : false

        block_8 = resource_blocks["block_8"]
        name_resource_8 = block_8["name"]
        sc_resource_8 = block_8["start_capacity"]
        bc_resource_8 = block_8["build_cost"]
        sbp_resource_8 = block_8["backlash_risk"]
        backend_data_name_8 = block_8["EDG_data_name"]
        is_new_resource_8 = block_8["new_resource"]
        name_resource_8 = is_new_resource_8 ? name_resource_8 : name_resource_8 * " (EXISTING)"
        cum_cap_resource_8 = sc_resource_8
        bb_name_resource_8 = is_new_resource_8 ? "Added capacity" : "Retained capacity"
        b_color_resource_8 = is_new_resource_8 ? "border: 2px solid rgb(16, 16, 129);" : "border: 2px solid rgb(255, 198, 151);"
        b_color_resource_8 *= backend_data_name_8 == "clean_firm" ? color_select : ""
        is_clean_firm_resource_8 = backend_data_name_8 == "clean_firm" ? true : false

        # Uncertainty parameters
        uncertainty_parameters = _game_setup["uncertainty_parameters"]
        up_demand_variance = uncertainty_parameters["Demand_Variance"]
        up_disaster_probability = uncertainty_parameters["Disaster_Probability"]
        up_outage_probability = uncertainty_parameters["Outage_Probability"]
        up_outage_rate = uncertainty_parameters["Outage_Rate"]

        # Experience rate is decline in technology cost for each build point spent on each resource
        experience_rate = _game_setup["experience_rate"]

        # Backlash rates are probability used in a Bernoulli distribution with one draw per build point spent on each resource (halved by Shaping points)
        backlash_rates = DataFrame(_game_setup["backlash_rates"])
        br_none = backlash_rates.none[1]
        br_low = backlash_rates.low[1]
        br_moderate = backlash_rates.moderate[1]
        br_high = backlash_rates.high[1]

        # Scoring setup
        scoring_parameters = _game_setup["scoring_parameters"]
        sp_max_points = scoring_parameters["Max_Points"]
        sp_clean_stage_1 = scoring_parameters["Clean_Stage_1"]
        sp_clean_stage_2 = scoring_parameters["Clean_Stage_2"]
        sp_clean_stage_3 = scoring_parameters["Clean_Stage_3"]
        sp_reliability = scoring_parameters["Reliability"]

        # Load prevoius stage data (if available)
        if current_stage > 1
            is_WY_setup = _game_setup["is_WY_setup"]

            social_backlash_resource_1 = resource_blocks["block_1"]["social_backlash"]
            social_backlash_resource_2 = resource_blocks["block_2"]["social_backlash"]
            social_backlash_resource_3 = resource_blocks["block_3"]["social_backlash"]
            social_backlash_resource_4 = resource_blocks["block_4"]["social_backlash"]
            social_backlash_resource_5 = resource_blocks["block_5"]["social_backlash"]
            social_backlash_resource_6 = resource_blocks["block_6"]["social_backlash"]
            social_backlash_resource_7 = resource_blocks["block_7"]["social_backlash"]
            social_backlash_resource_8 = resource_blocks["block_8"]["social_backlash"]

            available_shaping_tokens = sum(values(_game_setup["shaping_tokens"]))

            # shaping tokens
            if _game_setup["shaping_tokens"]["resilience"]
                bt_resilience = true
                bt_resilience_is_disabled = true
            end
            if _game_setup["shaping_tokens"]["innovation_experience"]
                bt_innovation_experience = true
                bt_innovation_experience_is_disabled = true
            end
            if _game_setup["shaping_tokens"]["innovation_clean_firm"]
                bt_innovation_clean_firm = true
                bt_innovation_clean_firm_is_disabled = true
                is_clean_firm_resource_1 = false
                is_clean_firm_resource_2 = false
                is_clean_firm_resource_3 = false
                is_clean_firm_resource_4 = false
                is_clean_firm_resource_5 = false
                is_clean_firm_resource_6 = false
                is_clean_firm_resource_7 = false
                is_clean_firm_resource_8 = false
                b_color_resource_1 = replace(b_color_resource_1, color_select => "")
                b_color_resource_2 = replace(b_color_resource_2, color_select => "")
                b_color_resource_3 = replace(b_color_resource_3, color_select => "")
                b_color_resource_4 = replace(b_color_resource_4, color_select => "")
                b_color_resource_5 = replace(b_color_resource_5, color_select => "")
                b_color_resource_6 = replace(b_color_resource_6, color_select => "")
                b_color_resource_7 = replace(b_color_resource_7, color_select => "")
                b_color_resource_8 = replace(b_color_resource_8, color_select => "")
            end
            if _game_setup["shaping_tokens"]["social_license"]
                bt_social_license = true
                bt_social_license_is_disabled = true
            end
            # update scores
            reliability_score_stage_1 = _game_setup["reliability_scores"][1]
            reliability_score_stage_2 = _game_setup["reliability_scores"][2]
            reliability_score_stage_3 = _game_setup["reliability_scores"][3]
            reliability_score_stage_4 = _game_setup["reliability_scores"][4]
            reliability_score_stage_5 = _game_setup["reliability_scores"][5]
            clean_score_stage_1 = _game_setup["clean_scores"][1]
            clean_score_stage_2 = _game_setup["clean_scores"][2]
            clean_score_stage_3 = _game_setup["clean_scores"][3]
            clean_score_stage_4 = _game_setup["clean_scores"][4]
            clean_score_stage_5 = _game_setup["clean_scores"][5]
            total_score = sum([reliability_score_stage_1, reliability_score_stage_2, reliability_score_stage_3, reliability_score_stage_4, reliability_score_stage_5, clean_score_stage_1, clean_score_stage_2, clean_score_stage_3, clean_score_stage_4, clean_score_stage_5])

            if game_over
                affordability_score = 3 * available_budget_tokens
                total_score += affordability_score
            end

            # update built capacity from prevoius stages
            cap_resource_1_stage_1 = get(_game_setup["resource_blocks"]["block_1"], "cap_built_stage_1", 0)
            cap_resource_2_stage_1 = get(_game_setup["resource_blocks"]["block_2"], "cap_built_stage_1", 0)
            cap_resource_3_stage_1 = get(_game_setup["resource_blocks"]["block_3"], "cap_built_stage_1", 0)
            cap_resource_4_stage_1 = get(_game_setup["resource_blocks"]["block_4"], "cap_built_stage_1", 0)
            cap_resource_5_stage_1 = get(_game_setup["resource_blocks"]["block_5"], "cap_built_stage_1", 0)
            cap_resource_6_stage_1 = get(_game_setup["resource_blocks"]["block_6"], "cap_built_stage_1", 0)
            cap_resource_7_stage_1 = get(_game_setup["resource_blocks"]["block_7"], "cap_built_stage_1", 0)
            cap_resource_8_stage_1 = get(_game_setup["resource_blocks"]["block_8"], "cap_built_stage_1", 0)

            cap_resource_1_stage_2 = get(_game_setup["resource_blocks"]["block_1"], "cap_built_stage_2", 0)
            cap_resource_2_stage_2 = get(_game_setup["resource_blocks"]["block_2"], "cap_built_stage_2", 0)
            cap_resource_3_stage_2 = get(_game_setup["resource_blocks"]["block_3"], "cap_built_stage_2", 0)
            cap_resource_4_stage_2 = get(_game_setup["resource_blocks"]["block_4"], "cap_built_stage_2", 0)
            cap_resource_5_stage_2 = get(_game_setup["resource_blocks"]["block_5"], "cap_built_stage_2", 0)
            cap_resource_6_stage_2 = get(_game_setup["resource_blocks"]["block_6"], "cap_built_stage_2", 0)
            cap_resource_7_stage_2 = get(_game_setup["resource_blocks"]["block_7"], "cap_built_stage_2", 0)
            cap_resource_8_stage_2 = get(_game_setup["resource_blocks"]["block_8"], "cap_built_stage_2", 0)

            cap_resource_1_stage_3 = get(_game_setup["resource_blocks"]["block_1"], "cap_built_stage_3", 0)
            cap_resource_2_stage_3 = get(_game_setup["resource_blocks"]["block_2"], "cap_built_stage_3", 0)
            cap_resource_3_stage_3 = get(_game_setup["resource_blocks"]["block_3"], "cap_built_stage_3", 0)
            cap_resource_4_stage_3 = get(_game_setup["resource_blocks"]["block_4"], "cap_built_stage_3", 0)
            cap_resource_5_stage_3 = get(_game_setup["resource_blocks"]["block_5"], "cap_built_stage_3", 0)
            cap_resource_6_stage_3 = get(_game_setup["resource_blocks"]["block_6"], "cap_built_stage_3", 0)
            cap_resource_7_stage_3 = get(_game_setup["resource_blocks"]["block_7"], "cap_built_stage_3", 0)
            cap_resource_8_stage_3 = get(_game_setup["resource_blocks"]["block_8"], "cap_built_stage_3", 0)

            cap_resource_1_stage_4 = get(_game_setup["resource_blocks"]["block_1"], "cap_built_stage_4", 0)
            cap_resource_2_stage_4 = get(_game_setup["resource_blocks"]["block_2"], "cap_built_stage_4", 0)
            cap_resource_3_stage_4 = get(_game_setup["resource_blocks"]["block_3"], "cap_built_stage_4", 0)
            cap_resource_4_stage_4 = get(_game_setup["resource_blocks"]["block_4"], "cap_built_stage_4", 0)
            cap_resource_5_stage_4 = get(_game_setup["resource_blocks"]["block_5"], "cap_built_stage_4", 0)
            cap_resource_6_stage_4 = get(_game_setup["resource_blocks"]["block_6"], "cap_built_stage_4", 0)
            cap_resource_7_stage_4 = get(_game_setup["resource_blocks"]["block_7"], "cap_built_stage_4", 0)
            cap_resource_8_stage_4 = get(_game_setup["resource_blocks"]["block_8"], "cap_built_stage_4", 0)

            cap_resource_1_stage_5 = get(_game_setup["resource_blocks"]["block_1"], "cap_built_stage_5", 0)
            cap_resource_2_stage_5 = get(_game_setup["resource_blocks"]["block_2"], "cap_built_stage_5", 0)
            cap_resource_3_stage_5 = get(_game_setup["resource_blocks"]["block_3"], "cap_built_stage_5", 0)
            cap_resource_4_stage_5 = get(_game_setup["resource_blocks"]["block_4"], "cap_built_stage_5", 0)
            cap_resource_5_stage_5 = get(_game_setup["resource_blocks"]["block_5"], "cap_built_stage_5", 0)
            cap_resource_6_stage_5 = get(_game_setup["resource_blocks"]["block_6"], "cap_built_stage_5", 0)
            cap_resource_7_stage_5 = get(_game_setup["resource_blocks"]["block_7"], "cap_built_stage_5", 0)
            cap_resource_8_stage_5 = get(_game_setup["resource_blocks"]["block_8"], "cap_built_stage_5", 0)

            bt_resource_1 = 0
            bt_resource_2 = 0
            bt_resource_3 = 0
            bt_resource_4 = 0
            bt_resource_5 = 0
            bt_resource_6 = 0
            bt_resource_7 = 0
            bt_resource_8 = 0
        end
    end

    # buy build tokens
    @onbutton bt_buy_build_token begin
        if available_budget_tokens >= 1
            available_build_tokens += 2
            available_budget_tokens -= 1
        end
    end
    @onbutton bt_undo_buy_build_token begin
        if (available_budget_tokens < _current_stage_budget_tokens)
            available_build_tokens -= 2
            available_budget_tokens += 1
        end
    end

    # buttons to buy/undo new capacity for each resource
    @onbutton resource_1_build_p begin
        if available_build_tokens > 0
            new_cap = (bt_resource_1 + 1) * bc_resource_1[1]
            if (is_new_resource_1) || (new_cap <= sc_resource_1)
                if current_stage == 1
                    cap_resource_1_stage_1 = new_cap
                elseif current_stage == 2
                    cap_resource_1_stage_2 = new_cap
                elseif current_stage == 3
                    cap_resource_1_stage_3 = new_cap
                elseif current_stage == 4
                    cap_resource_1_stage_4 = new_cap
                elseif current_stage == 5
                    cap_resource_1_stage_5 = new_cap
                end
                bt_resource_1 += 1
                available_build_tokens -= 1
                cum_cap_resource_1 = is_new_resource_1 ? sc_resource_1 + new_cap : sc_resource_1
            else
                return
            end
        end
    end
    @onbutton resource_1_build_m begin
        if bt_resource_1 > 0
            bt_resource_1 -= 1
            available_build_tokens += 1
            new_cap = bt_resource_1 * bc_resource_1[1]
            if current_stage == 1
                cap_resource_1_stage_1 = new_cap
            elseif current_stage == 2
                cap_resource_1_stage_2 = new_cap
            elseif current_stage == 3
                cap_resource_1_stage_3 = new_cap
            elseif current_stage == 4
                cap_resource_1_stage_4 = new_cap
            elseif current_stage == 5
                cap_resource_1_stage_5 = new_cap
            end
            cum_cap_resource_1 = is_new_resource_1 ? sc_resource_1 + new_cap : sc_resource_1
        end
    end

    @onbutton resource_2_build_p begin
        if available_build_tokens > 0
            new_cap = (bt_resource_2 + 1) * bc_resource_2[1]
            if (is_new_resource_2) || (new_cap <= sc_resource_2)
                if current_stage == 1
                    cap_resource_2_stage_1 = new_cap
                elseif current_stage == 2
                    cap_resource_2_stage_2 = new_cap
                elseif current_stage == 3
                    cap_resource_2_stage_3 = new_cap
                elseif current_stage == 4
                    cap_resource_2_stage_4 = new_cap
                elseif current_stage == 5
                    cap_resource_2_stage_5 = new_cap
                end
                bt_resource_2 += 1
                available_build_tokens -= 1
                cum_cap_resource_2 = is_new_resource_2 ? sc_resource_2 + new_cap : sc_resource_2
            else
                return
            end
        end
    end
    @onbutton resource_2_build_m begin
        if bt_resource_2 > 0
            bt_resource_2 -= 1
            available_build_tokens += 1
            new_cap = bt_resource_2 * bc_resource_2[1]
            if current_stage == 1
                cap_resource_2_stage_1 = new_cap
            elseif current_stage == 2
                cap_resource_2_stage_2 = new_cap
            elseif current_stage == 3
                cap_resource_2_stage_3 = new_cap
            elseif current_stage == 4
                cap_resource_2_stage_4 = new_cap
            elseif current_stage == 5
                cap_resource_2_stage_5 = new_cap
            end
            cum_cap_resource_2 = is_new_resource_2 ? sc_resource_2 + new_cap : sc_resource_2
        end
    end

    @onbutton resource_3_build_p begin
        if available_build_tokens > 0
            new_cap = (bt_resource_3 + 1) * bc_resource_3[1]
            if (is_new_resource_3) || (new_cap <= sc_resource_3)
                if current_stage == 1
                    cap_resource_3_stage_1 = new_cap
                elseif current_stage == 2
                    cap_resource_3_stage_2 = new_cap
                elseif current_stage == 3
                    cap_resource_3_stage_3 = new_cap
                elseif current_stage == 4
                    cap_resource_3_stage_4 = new_cap
                elseif current_stage == 5
                    cap_resource_3_stage_5 = new_cap
                end
                bt_resource_3 += 1
                available_build_tokens -= 1
                cum_cap_resource_3 = is_new_resource_3 ? sc_resource_3 + new_cap : sc_resource_3
            else
                return
            end
        end
    end
    @onbutton resource_3_build_m begin
        if bt_resource_3 > 0
            bt_resource_3 -= 1
            available_build_tokens += 1
            new_cap = bt_resource_3 * bc_resource_3[1]
            if current_stage == 1
                cap_resource_3_stage_1 = new_cap
            elseif current_stage == 2
                cap_resource_3_stage_2 = new_cap
            elseif current_stage == 3
                cap_resource_3_stage_3 = new_cap
            elseif current_stage == 4
                cap_resource_3_stage_4 = new_cap
            elseif current_stage == 5
                cap_resource_3_stage_5 = new_cap
            end
            cum_cap_resource_3 = is_new_resource_3 ? sc_resource_3 + new_cap : sc_resource_3
        end
    end

    @onbutton resource_4_build_p begin
        if available_build_tokens > 0
            new_cap = (bt_resource_4 + 1) * bc_resource_4[1]
            if (is_new_resource_4) || (new_cap <= sc_resource_4)
                if current_stage == 1
                    cap_resource_4_stage_1 = new_cap
                elseif current_stage == 2
                    cap_resource_4_stage_2 = new_cap
                elseif current_stage == 3
                    cap_resource_4_stage_3 = new_cap
                elseif current_stage == 4
                    cap_resource_4_stage_4 = new_cap
                elseif current_stage == 5
                    cap_resource_4_stage_5 = new_cap
                end
                bt_resource_4 += 1
                available_build_tokens -= 1
                cum_cap_resource_4 = is_new_resource_4 ? sc_resource_4 + new_cap : sc_resource_4
            else
                return
            end
        end
    end
    @onbutton resource_4_build_m begin
        if bt_resource_4 > 0
            bt_resource_4 -= 1
            available_build_tokens += 1
            new_cap = bt_resource_4 * bc_resource_4[1]
            if current_stage == 1
                cap_resource_4_stage_1 = new_cap
            elseif current_stage == 2
                cap_resource_4_stage_2 = new_cap
            elseif current_stage == 3
                cap_resource_4_stage_3 = new_cap
            elseif current_stage == 4
                cap_resource_4_stage_4 = new_cap
            elseif current_stage == 5
                cap_resource_4_stage_5 = new_cap
            end
            cum_cap_resource_4 = is_new_resource_4 ? sc_resource_4 + new_cap : sc_resource_4
        end
    end

    @onbutton resource_5_build_p begin
        if available_build_tokens > 0
            new_cap = (bt_resource_5 + 1) * bc_resource_5[1]
            if (is_new_resource_5) || (new_cap <= sc_resource_5)
                if current_stage == 1
                    cap_resource_5_stage_1 = new_cap
                elseif current_stage == 2
                    cap_resource_5_stage_2 = new_cap
                elseif current_stage == 3   
                    cap_resource_5_stage_3 = new_cap
                elseif current_stage == 4
                    cap_resource_5_stage_4 = new_cap
                elseif current_stage == 5
                    cap_resource_5_stage_5 = new_cap
                end
                bt_resource_5 += 1
                available_build_tokens -= 1
                cum_cap_resource_5 = is_new_resource_5 ? sc_resource_5 + new_cap : sc_resource_5
            else
                return
            end
        end
    end
    @onbutton resource_5_build_m begin
        if bt_resource_5 > 0
            bt_resource_5 -= 1
            available_build_tokens += 1
            new_cap = bt_resource_5 * bc_resource_5[1]
            if current_stage == 1
                cap_resource_5_stage_1 = new_cap
            elseif current_stage == 2
                cap_resource_5_stage_2 = new_cap
            elseif current_stage == 3
                cap_resource_5_stage_3 = new_cap
            elseif current_stage == 4
                cap_resource_5_stage_4 = new_cap
            elseif current_stage == 5
                cap_resource_5_stage_5 = new_cap
            end
            cum_cap_resource_5 = is_new_resource_5 ? sc_resource_5 + new_cap : sc_resource_5
        end
    end

    @onbutton resource_6_build_p begin
        if available_build_tokens > 0
            new_cap = (bt_resource_6 + 1) * bc_resource_6[1]
            if (is_new_resource_6) || (new_cap <= sc_resource_6)
                if current_stage == 1
                    cap_resource_6_stage_1 = new_cap
                elseif current_stage == 2
                    cap_resource_6_stage_2 = new_cap
                elseif current_stage == 3
                    cap_resource_6_stage_3 = new_cap
                elseif current_stage == 4
                    cap_resource_6_stage_4 = new_cap
                elseif current_stage == 5
                    cap_resource_6_stage_5 = new_cap
                end
                bt_resource_6 += 1
                available_build_tokens -= 1
                cum_cap_resource_6 = is_new_resource_6 ? sc_resource_6 + new_cap : sc_resource_6
            else
                return
            end
        end
    end
    @onbutton resource_6_build_m begin
        if bt_resource_6 > 0
            bt_resource_6 -= 1
            available_build_tokens += 1
            new_cap = bt_resource_6 * bc_resource_6[1]
            if current_stage == 1
                cap_resource_6_stage_1 = new_cap
            elseif current_stage == 2
                cap_resource_6_stage_2 = new_cap
            elseif current_stage == 3
                cap_resource_6_stage_3 = new_cap
            elseif current_stage == 4
                cap_resource_6_stage_4 = new_cap
            elseif current_stage == 5
                cap_resource_6_stage_5 = new_cap
            end
            cum_cap_resource_6 = is_new_resource_6 ? sc_resource_6 + new_cap : sc_resource_6
        end
    end

    @onbutton resource_7_build_p begin
        if available_build_tokens > 0
            new_cap = (bt_resource_7 + 1) * bc_resource_7[1]
            if (is_new_resource_7) || (new_cap <= sc_resource_7)
                if current_stage == 1
                    cap_resource_7_stage_1 = new_cap
                elseif current_stage == 2
                    cap_resource_7_stage_2 = new_cap
                elseif current_stage == 3
                    cap_resource_7_stage_3 = new_cap
                elseif current_stage == 4
                    cap_resource_7_stage_4 = new_cap
                elseif current_stage == 5
                    cap_resource_7_stage_5 = new_cap
                end
                bt_resource_7 += 1
                available_build_tokens -= 1
                cum_cap_resource_7 = is_new_resource_7 ? sc_resource_7 + new_cap : sc_resource_7
            else
                return
            end
        end
    end
    @onbutton resource_7_build_m begin
        if bt_resource_7 > 0
            bt_resource_7 -= 1
            available_build_tokens += 1
            new_cap = bt_resource_7 * bc_resource_7[1]
            if current_stage == 1
                cap_resource_7_stage_1 = new_cap
            elseif current_stage == 2
                cap_resource_7_stage_2 = new_cap
            elseif current_stage == 3
                cap_resource_7_stage_3 = new_cap
            elseif current_stage == 4
                cap_resource_7_stage_4 = new_cap
            elseif current_stage == 5
                cap_resource_7_stage_5 = new_cap
            end
            cum_cap_resource_7 = is_new_resource_7 ? sc_resource_7 + new_cap : sc_resource_7
        end
    end

    @onbutton resource_8_build_p begin
        if available_build_tokens > 0
            new_cap = (bt_resource_8 + 1) * bc_resource_8[1]
            if (is_new_resource_8) || (new_cap <= sc_resource_8)
                if current_stage == 1
                    cap_resource_8_stage_1 = new_cap
                elseif current_stage == 2
                    cap_resource_8_stage_2 = new_cap
                elseif current_stage == 3
                    cap_resource_8_stage_3 = new_cap
                elseif current_stage == 4
                    cap_resource_8_stage_4 = new_cap
                elseif current_stage == 5
                    cap_resource_8_stage_5 = new_cap
                end
                bt_resource_8 += 1
                available_build_tokens -= 1
                cum_cap_resource_8 = is_new_resource_8 ? sc_resource_8 + new_cap : sc_resource_8
            else
                return
            end
        end
    end
    @onbutton resource_8_build_m begin
        if bt_resource_8 > 0
            bt_resource_8 -= 1
            available_build_tokens += 1
            new_cap = bt_resource_8 * bc_resource_8[1]
            if current_stage == 1
                cap_resource_8_stage_1 = new_cap
            elseif current_stage == 2
                cap_resource_8_stage_2 = new_cap
            elseif current_stage == 3
                cap_resource_8_stage_3 = new_cap
            elseif current_stage == 4
                cap_resource_8_stage_4 = new_cap
            elseif current_stage == 5
                cap_resource_8_stage_5 = new_cap
            end
            cum_cap_resource_8 = is_new_resource_8 ? sc_resource_8 + new_cap : sc_resource_8
        end
    end

    # update budget tokens and affordability score based on available budget tokens
    @onchange available_budget_tokens begin
        if available_budget_tokens == 5
            bt_color_1 = bt_color_2 = bt_color_3 = bt_color_4 = bt_color_5 = "border: 1px solid black; background-color: rgb(160, 218, 170);"
        elseif available_budget_tokens == 4
            bt_color_1 = bt_color_2 = bt_color_3 = bt_color_4 = "border: 1px solid black; background-color: rgb(160, 218, 170);"
            bt_color_5 = "border: 1px solid black;"
        elseif available_budget_tokens == 3
            bt_color_1 = bt_color_2 = bt_color_3 = "border: 1px solid black; background-color: rgb(160, 218, 170);"
            bt_color_4 = bt_color_5 = "border: 1px solid black;"
        elseif available_budget_tokens == 2
            bt_color_1 = bt_color_2 = "border: 1px solid black; background-color: rgb(160, 218, 170);"
            bt_color_3 = bt_color_4 = bt_color_5 = "border: 1px solid black;"
        elseif available_budget_tokens == 1
            bt_color_1 = "border: 1px solid black; background-color: rgb(160, 218, 170);"
            bt_color_2 = bt_color_3 = bt_color_4 = bt_color_5 = "border: 1px solid black;"
        elseif available_budget_tokens == 0
            bt_color_1 = bt_color_2 = bt_color_3 = bt_color_4 = bt_color_5 = "border: 1px solid black;"
        end
        affordability_score = 3 * available_budget_tokens
    end

    # setup backend data structure and run simulation
    @onbutton run_simulation begin
        tab = "Simulation Results"
        # Compile resource parameters dict
        backend_data_name = [backend_data_name_1,
            backend_data_name_2,
            backend_data_name_3,
            backend_data_name_4,
            backend_data_name_5,
            backend_data_name_6,
            backend_data_name_7,
            backend_data_name_8
        ]

        start_capacity = DataFrame(
            resource_1=sc_resource_1,
            resource_2=sc_resource_2,
            resource_3=sc_resource_3,
            resource_4=sc_resource_4,
            resource_5=sc_resource_5,
            resource_6=sc_resource_6,
            resource_7=sc_resource_7,
            resource_8=sc_resource_8
        )
        rename!(start_capacity, backend_data_name)

        build_tokens = DataFrame(
            resource_1=bt_resource_1,
            resource_2=bt_resource_2,
            resource_3=bt_resource_3,
            resource_4=bt_resource_4,
            resource_5=bt_resource_5,
            resource_6=bt_resource_6,
            resource_7=bt_resource_7,
            resource_8=bt_resource_8
        )
        rename!(build_tokens, backend_data_name)

        build_cost = DataFrame(
            resource_1=bc_resource_1,
            resource_2=bc_resource_2,
            resource_3=bc_resource_3,
            resource_4=bc_resource_4,
            resource_5=bc_resource_5,
            resource_6=bc_resource_6,
            resource_7=bc_resource_7,
            resource_8=bc_resource_8
        )
        rename!(build_cost, backend_data_name)

        resource_params = Dict(
            "Start_Capacity" => start_capacity,
            "Build_Cost" => build_cost,
            "Build_Tokens" => build_tokens,
        )

        scoring_params = Dict(
            "Max_Points" => sp_max_points,
            "Clean_Stage_1" => sp_clean_stage_1,
            "Clean_Stage_2" => sp_clean_stage_2,
            "Clean_Stage_3" => sp_clean_stage_3,
            "Clean_Stage_4" => sp_clean_stage_4,
            "Clean_Stage_5" => sp_clean_stage_5,
            "Reliability" => sp_reliability
        )

        scores, dispatch_results, resource_results = run_simulation(current_stage, year, resource_params, scoring_params, is_new_nuclear=is_new_resource_7)
        
        ## update scores
        Reliability = scores[!, :Reliability][1]
        Reliability_Points = scores[!, :Reliability_Points][1]
        Clean_Share = scores[!, :Clean_Share][1]
        Clean_Points = scores[!, :Clean_Points][1]

        ## plotting
        plot_week = 1
        plot_full_year = true
        df = copy(dispatch_results)
        rename!(df, "nuclear" => "Nuclear")
        rename!(df, "natural_gas" => "Natural Gas")
        rename!(df, "clean_firm" => "Clean Firm")
        rename!(df, "solar_pv" => "Solar PV (Utility Scale)")
        rename!(df, "distributed_solar" => "Distributed Solar PV")
        rename!(df, "onshore_wind" => "Onshore Wind")
        rename!(df, "offshore_wind" => "Offshore Wind")
        rename!(df, "battery" => "Battery Discharge")
        rename!(df, "battery_charge" => "Battery Charge")
        rename!(df, "demand_not_served" => "Demand not served")
        # sort columns by cumulative capacity
        sorted_idx = sortperm([1,1,1,cum_cap_resource_5,1,cum_cap_resource_8,cum_cap_resource_7,cum_cap_resource_2,cum_cap_resource_4,cum_cap_resource_1,cum_cap_resource_3,cum_cap_resource_5,cum_cap_resource_6])
        cols = names(df)[sorted_idx]
        select!(df, cols)
        # move battery charge and demand not served to the beginning
        df = df[!, ["Battery Charge","Demand not served", setdiff(names(df), ["Battery Charge","Demand not served"])...]]
        # select non-zero columns
        df = df[!, [col for col in names(df) if sum(df[!, col]) != 0]]
        plot_df = df
        plot_traces = get_traces(plot_df, plot_week, plot_full_year, plot_colors, is_WY_setup)
    end

    # update plot based on selected week
    @onchange plot_week begin
        if plot_full_year && plot_week != 1
            plot_week = 1
        end
        if !plot_full_year && !isempty(plot_df)
            plot_traces = get_traces(plot_df, plot_week, plot_full_year, plot_colors, is_WY_setup)
            PlotlyBase.relayout!(plot_layout, xaxis=attr(title="Day", showgrid=true, dtick=1))
            plot_layout = plot_layout
        end
    end

    # update plot when switching to full year view
    @onchange plot_full_year begin
        if plot_full_year
            plot_week = 1
        end
        if !isempty(plot_df)
            plot_traces = get_traces(plot_df, plot_week, plot_full_year, plot_colors, is_WY_setup)
            if plot_full_year
                PlotlyBase.relayout!(plot_layout, xaxis=attr(title="Week", showgrid=true, dtick=5))
            else
                PlotlyBase.relayout!(plot_layout, xaxis=attr(title="Day", showgrid=true, dtick=1))
            end
            plot_layout = plot_layout
        end
    end

    @onbutton bt_buy_shaping_token begin
        if available_budget_tokens >= 1 && available_shaping_tokens < 4
            available_shaping_tokens += 1
            available_budget_tokens -= 1
        end
    end
    @onbutton bt_undo_buy_shaping_token begin
        if (available_budget_tokens <= _current_stage_budget_tokens) && (available_shaping_tokens > _current_stage_shaping_tokens)
            available_shaping_tokens -= 1
            available_budget_tokens += 1
        end
    end

    @onchange bt_resilience begin
        if bt_resilience
            if available_shaping_tokens > 0
                available_shaping_tokens -= 1
                resilience = true
            else
                bt_resilience = false
                available_shaping_tokens -= 1
            end
        else
            resilience = false
            available_shaping_tokens += 1
        end
    end

    @onchange bt_innovation_experience begin
        if bt_innovation_experience
            if available_shaping_tokens > 0
                available_shaping_tokens -= 1
                innovation_experience = true
            else
                bt_innovation_experience = false
                available_shaping_tokens -= 1
            end
        else
            innovation_experience = false
            available_shaping_tokens += 1
        end
    end

    @onchange bt_innovation_clean_firm begin
        if bt_innovation_clean_firm
            if available_shaping_tokens > 0
                available_shaping_tokens -= 1
                innovation_clean_firm = true
            else
                bt_innovation_clean_firm = false
                available_shaping_tokens -= 1
            end
        else
            innovation_clean_firm = false
            available_shaping_tokens += 1
        end
    end

    @onchange bt_social_license begin
        if bt_social_license
            if available_shaping_tokens > 0
                available_shaping_tokens -= 1
                social_license = true
            else
                bt_social_license = false
                available_shaping_tokens -= 1
            end
        else
            social_license = false
            available_shaping_tokens += 1
        end
    end

    @onchange plot_stage_week begin
        if plot_stage_full_year && plot_stage_week != 1
            plot_stage_week = 1
        end
        if !plot_stage_full_year && !isempty(plot_stage_results)
            plot_stage_traces = get_traces(plot_stage_results, plot_stage_week, plot_stage_full_year, plot_colors, is_WY_setup)
            PlotlyBase.relayout!(plot_stage_layout, xaxis=attr(title="Day", showgrid=true, dtick=1))
            plot_stage_layout = plot_stage_layout
        end
    end

    @onchange plot_stage_full_year begin
        if plot_stage_full_year
            plot_stage_week = 1
        end
        if !isempty(plot_stage_results)
            plot_stage_traces = get_traces(plot_stage_results, plot_stage_week, plot_stage_full_year, plot_colors, is_WY_setup)
            if plot_stage_full_year
                PlotlyBase.relayout!(plot_stage_layout, xaxis=attr(title="Week", showgrid=true, dtick=5))
            else
                PlotlyBase.relayout!(plot_stage_layout, xaxis=attr(title="Day", showgrid=true, dtick=1))
            end
            plot_stage_layout = plot_stage_layout
        end
    end

    @onchange social_backlash_resource_1 begin
        if social_backlash_resource_1
            bt_resource_1_disabled = "background-color: red; color: white"
        else
            bt_resource_1_disabled = ""
        end
    end

    @onchange social_backlash_resource_2 begin
        if social_backlash_resource_2
            bt_resource_2_disabled = "background-color: red; color: white"
        else
            bt_resource_2_disabled = ""
        end
    end

    @onchange social_backlash_resource_3 begin
        if social_backlash_resource_3
            bt_resource_3_disabled = "background-color: red; color: white"
        else
            bt_resource_3_disabled = ""
        end
    end

    @onchange social_backlash_resource_4 begin
        if social_backlash_resource_4
            bt_resource_4_disabled = "background-color: red; color: white"
        else
            bt_resource_4_disabled = ""
        end
    end

    @onchange social_backlash_resource_5 begin
        if social_backlash_resource_5
            bt_resource_5_disabled = "background-color: red; color: white"
        else
            bt_resource_5_disabled = ""
        end
    end

    @onchange social_backlash_resource_6 begin
        if social_backlash_resource_6
            bt_resource_6_disabled = "background-color: red; color: white"
        else
            bt_resource_6_disabled = ""
        end
    end

    @onchange social_backlash_resource_7 begin
        if social_backlash_resource_7
            bt_resource_7_disabled = "background-color: red; color: white"
        else
            bt_resource_7_disabled = ""
        end
    end

    @onchange social_backlash_resource_8 begin
        if social_backlash_resource_8
            bt_resource_8_disabled = "background-color: red; color: white"
        else
            bt_resource_8_disabled = ""
        end
    end

    # advance stage
    @onchange confirm_advance_stage begin
        if available_shaping_tokens == 0
            shaping_tokens_warning = "display: none"
        else
            shaping_tokens_warning = "display: "
        end
    end

    @onbutton back_to_build_tab begin
        tab = "Build"
    end

    @onbutton advance_stage begin
        # Compile resource parameters dict
        backend_data_name = [backend_data_name_1,
            backend_data_name_2,
            backend_data_name_3,
            backend_data_name_4,
            backend_data_name_5,
            backend_data_name_6,
            backend_data_name_7,
            backend_data_name_8
        ]

        start_capacity = DataFrame(
            resource_1=sc_resource_1,
            resource_2=sc_resource_2,
            resource_3=sc_resource_3,
            resource_4=sc_resource_4,
            resource_5=sc_resource_5,
            resource_6=sc_resource_6,
            resource_7=sc_resource_7,
            resource_8=sc_resource_8
        )
        rename!(start_capacity, backend_data_name)

        # capacity of first stage is equal to build tokens * build cost
        build_tokens = DataFrame(
            resource_1=bt_resource_1,
            resource_2=bt_resource_2,
            resource_3=bt_resource_3,
            resource_4=bt_resource_4,
            resource_5=bt_resource_5,
            resource_6=bt_resource_6,
            resource_7=bt_resource_7,
            resource_8=bt_resource_8
        )
        rename!(build_tokens, backend_data_name)

        build_cost = DataFrame(
            resource_1=bc_resource_1,
            resource_2=bc_resource_2,
            resource_3=bc_resource_3,
            resource_4=bc_resource_4,
            resource_5=bc_resource_5,
            resource_6=bc_resource_6,
            resource_7=bc_resource_7,
            resource_8=bc_resource_8
        )
        rename!(build_cost, backend_data_name)

        resource_params = Dict(
            "Start_Capacity" => start_capacity,
            "Build_Cost" => build_cost,
            "Build_Tokens" => build_tokens
        )

        _shaping_tokens = Dict(
            "Resilience" => resilience ? 1 : 0,
            "Innovation_Experience" => innovation_experience ? 1 : 0,
            "Innovation_Clean_Firm" => innovation_clean_firm ? 1 : 0,
            "Social_License" => social_license ? 1 : 0
        )

        _uncertainty_parameters = Dict(
            "Demand_Variance" => up_demand_variance,
            "Disaster_Probability" => up_disaster_probability,
            "Outage_Probability" => up_outage_probability,
            "Outage_Rate" => up_outage_rate
        )

        _scoring_parameters = Dict(
            "Max_Points" => sp_max_points,
            "Clean_Stage_1" => sp_clean_stage_1,
            "Clean_Stage_2" => sp_clean_stage_2,
            "Clean_Stage_3" => sp_clean_stage_3,
            "Clean_Stage_4" => sp_clean_stage_4,
            "Clean_Stage_5" => sp_clean_stage_5,
            "Reliability" => sp_reliability
        )

        _experience_rate = experience_rate

        _backlash_risk = DataFrame(
            resource_1=sbp_resource_1,
            resource_2=sbp_resource_2,
            resource_3=sbp_resource_3,
            resource_4=sbp_resource_4,
            resource_5=sbp_resource_5,
            resource_6=sbp_resource_6,
            resource_7=sbp_resource_7,
            resource_8=sbp_resource_8
        )
        rename!(_backlash_risk, backend_data_name)

        _backlash_rates = DataFrame(
            none=br_none,
            low=br_low,
            moderate=br_moderate,
            high=br_high
        )

        resource_params, dispatch_results, uncertainty_results, scores, social_backlash, experience_results = advance_stage(current_stage, year, resource_params, _shaping_tokens, _uncertainty_parameters, _scoring_parameters, _experience_rate, _backlash_risk, _backlash_rates, is_WY_setup=is_WY_setup, is_new_nuclear=is_new_resource_7)

        # update resource parameters
        start_capacity_running = resource_params["Start_Capacity"] ./ 1000
        sc_resource_1 = start_capacity_running[1, backend_data_name_1]
        sc_resource_2 = start_capacity_running[1, backend_data_name_2]
        sc_resource_3 = start_capacity_running[1, backend_data_name_3]
        sc_resource_4 = start_capacity_running[1, backend_data_name_4]
        sc_resource_5 = start_capacity_running[1, backend_data_name_5]
        sc_resource_6 = start_capacity_running[1, backend_data_name_6]
        sc_resource_7 = start_capacity_running[1, backend_data_name_7]
        sc_resource_8 = start_capacity_running[1, backend_data_name_8]

        cum_cap_resource_1 = sc_resource_1
        cum_cap_resource_2 = sc_resource_2
        cum_cap_resource_3 = sc_resource_3
        cum_cap_resource_4 = sc_resource_4
        cum_cap_resource_5 = sc_resource_5
        cum_cap_resource_6 = sc_resource_6
        cum_cap_resource_7 = sc_resource_7
        cum_cap_resource_8 = sc_resource_8

        # update scores
        stage_reliability = scores[1, :Reliability]
        stage_reliability_points = scores[1, :Reliability_Points]
        stage_clean_share = round(scores[1, :Clean_Share], digits=2)
        stage_clean_points = scores[1, :Clean_Points]

        # plot dispatch results
        plot_stage_week = 1
        plot_stage_full_year = true
        df = copy(dispatch_results)
        rename!(df, "nuclear" => "Nuclear")
        rename!(df, "natural_gas" => "Natural Gas")
        rename!(df, "clean_firm" => "Clean Firm")
        rename!(df, "solar_pv" => "Solar PV (Utility Scale)")
        rename!(df, "distributed_solar" => "Distributed Solar PV")
        rename!(df, "onshore_wind" => "Onshore Wind")
        rename!(df, "offshore_wind" => "Offshore Wind")
        rename!(df, "battery" => "Battery Discharge")
        rename!(df, "storage_charge" => "Battery Charge")
        rename!(df, "nonserved" => "Demand not served")
        # sort columns by cumulative capacity
        sorted_idx = sortperm([1,1,1,cum_cap_resource_5,1,cum_cap_resource_8,cum_cap_resource_7,cum_cap_resource_2,cum_cap_resource_4,cum_cap_resource_1,cum_cap_resource_3,cum_cap_resource_5,cum_cap_resource_6])
        cols = names(df)[sorted_idx]
        select!(df, cols)
        # move battery charge and demand not served to the beginning
        df = df[!, ["Battery Charge","Demand not served", setdiff(names(df), ["Battery Charge","Demand not served"])...]]
        # select non-zero columns
        df = df[!, [col for col in names(df) if sum(df[!, col]) != 0]]
        plot_stage_results = df
        plot_stage_traces = get_traces(plot_stage_results, plot_stage_week, plot_stage_full_year, plot_colors, is_WY_setup)

        # update costs
        bc_resource_1 = resource_params["Build_Cost"][1, backend_data_name_1]
        bc_resource_2 = resource_params["Build_Cost"][1, backend_data_name_2]
        bc_resource_3 = resource_params["Build_Cost"][1, backend_data_name_3]
        bc_resource_4 = resource_params["Build_Cost"][1, backend_data_name_4]
        bc_resource_5 = resource_params["Build_Cost"][1, backend_data_name_5]
        bc_resource_6 = resource_params["Build_Cost"][1, backend_data_name_6]
        bc_resource_7 = resource_params["Build_Cost"][1, backend_data_name_7]
        bc_resource_8 = resource_params["Build_Cost"][1, backend_data_name_8]

        # show social backlash and disaster results
        if uncertainty_results[1, "Disaster"] == true
            println("Disaster Occurred")
            disaster_occurred = "display: "
            outage_weeks = string(uncertainty_results[1, "Outage_Week"]) * " " * string(uncertainty_results[1, "Outage_Week"] + 1)
        else
            disaster_occurred = "display: none"
        end

        demand_shock_percent = uncertainty_results[1, "Demand_Shock_Percent"]

        disaster_resource_1 = Bool(uncertainty_results[1, backend_data_name_1])
        disaster_resource_2 = Bool(uncertainty_results[1, backend_data_name_2])
        disaster_resource_3 = Bool(uncertainty_results[1, backend_data_name_3])
        disaster_resource_4 = Bool(uncertainty_results[1, backend_data_name_4])
        disaster_resource_5 = Bool(uncertainty_results[1, backend_data_name_5])
        disaster_resource_6 = Bool(uncertainty_results[1, backend_data_name_6])
        disaster_resource_7 = Bool(uncertainty_results[1, backend_data_name_7])
        disaster_resource_8 = Bool(uncertainty_results[1, backend_data_name_8])

        # social backlash
        social_backlash_resource_1 = Bool(social_backlash[1, backend_data_name_1])
        social_backlash_resource_2 = Bool(social_backlash[1, backend_data_name_2])
        social_backlash_resource_3 = Bool(social_backlash[1, backend_data_name_3])
        social_backlash_resource_4 = Bool(social_backlash[1, backend_data_name_4])
        social_backlash_resource_5 = Bool(social_backlash[1, backend_data_name_5])
        social_backlash_resource_6 = Bool(social_backlash[1, backend_data_name_6])
        social_backlash_resource_7 = Bool(social_backlash[1, backend_data_name_7])
        social_backlash_resource_8 = Bool(social_backlash[1, backend_data_name_8])

        # reset build tokens
        bt_resource_1 = 0
        bt_resource_2 = 0
        bt_resource_3 = 0
        bt_resource_4 = 0
        bt_resource_5 = 0
        bt_resource_6 = 0
        bt_resource_7 = 0
        bt_resource_8 = 0

        _current_stage_budget_tokens = available_budget_tokens
        _current_stage_shaping_tokens = available_shaping_tokens

        # disable shaping if used
        if (resilience == true) && (bt_resilience_is_disabled == false)
            bt_resilience_is_disabled = true
        end
        if (innovation_experience == true) && (bt_innovation_experience_is_disabled == false)
            bt_innovation_experience_is_disabled = true
        end
        if (innovation_clean_firm == true) && (bt_innovation_clean_firm_is_disabled == false)
            bt_innovation_clean_firm_is_disabled = true
        end
        if (social_license == true) && (bt_social_license_is_disabled == false)
            bt_social_license_is_disabled = true
        end

        # enable clean_firm if shaping token is on
        if innovation_clean_firm
            is_clean_firm_resource_1 = false
            is_clean_firm_resource_2 = false
            is_clean_firm_resource_3 = false
            is_clean_firm_resource_4 = false
            is_clean_firm_resource_5 = false
            is_clean_firm_resource_6 = false
            is_clean_firm_resource_7 = false
            is_clean_firm_resource_8 = false
            b_color_resource_1 = replace(b_color_resource_1, color_select => "")
            b_color_resource_2 = replace(b_color_resource_2, color_select => "")
            b_color_resource_3 = replace(b_color_resource_3, color_select => "")
            b_color_resource_4 = replace(b_color_resource_4, color_select => "")
            b_color_resource_5 = replace(b_color_resource_5, color_select => "")
            b_color_resource_6 = replace(b_color_resource_6, color_select => "")
            b_color_resource_7 = replace(b_color_resource_7, color_select => "")
            b_color_resource_8 = replace(b_color_resource_8, color_select => "")
        end

        if current_stage == 1
            reliability_score_stage_1 = stage_reliability_points
            total_score += stage_reliability_points
            clean_score_stage_1 = stage_clean_points
            total_score += stage_clean_points
            affordability_score = 3 * available_budget_tokens
            if !is_WY_setup
                nuclear_relicensed = "display:"
            end
        elseif current_stage == 2
            reliability_score_stage_2 = stage_reliability_points
            total_score += stage_reliability_points
            clean_score_stage_2 = stage_clean_points
            total_score += stage_clean_points
            affordability_score = 3 * available_budget_tokens
            nuclear_relicensed = "display: none"
        elseif current_stage == 3
            reliability_score_stage_3 = stage_reliability_points
            total_score += stage_reliability_points
            clean_score_stage_3 = stage_clean_points
            total_score += stage_clean_points
            affordability_score = 3 * available_budget_tokens
        elseif current_stage == 4
            reliability_score_stage_4 = stage_reliability_points
            total_score += stage_reliability_points
            clean_score_stage_4 = stage_clean_points
            total_score += stage_clean_points
            affordability_score = 3 * available_budget_tokens
        elseif current_stage == 5
            reliability_score_stage_5 = stage_reliability_points
            total_score += stage_reliability_points
            clean_score_stage_5 = stage_clean_points
            total_score += stage_clean_points
            affordability_score = 3 * available_budget_tokens
            total_score += affordability_score
            println("Game Over")
            game_over = true
        end

        # advance stage
        current_stage += 1
        if current_stage <= 6
            println("Starting Stage ", current_stage)

            # write setup to file
            data = Dict(
                "scenario" => selected_file,
                "current_stage" => current_stage,
                "available_budget_tokens" => available_budget_tokens,
                "available_shaping_tokens" => _init_shaping_tokens,
                "current_stage_shaping_tokens" => available_shaping_tokens,
                "available_build_tokens" => _available_build_tokens,
                "is_WY_setup" => is_WY_setup,
                "stages" => _stages,
                "resource_blocks" => Dict(
                    "block_1" => Dict(
                        "name" => name_resource_1,
                        "start_capacity" => sc_resource_1,
                        "build_cost" => bc_resource_1,
                        "backlash_risk" => sbp_resource_1,
                        "EDG_data_name" => backend_data_name_1,
                        "new_resource" => is_new_resource_1,
                        "social_backlash" => social_backlash_resource_1,
                        "cap_built_stage_1" => cap_resource_1_stage_1,
                        "cap_built_stage_2" => cap_resource_1_stage_2,
                        "cap_built_stage_3" => cap_resource_1_stage_3
                    ),
                    "block_2" => Dict(
                        "name" => name_resource_2,
                        "start_capacity" => sc_resource_2,
                        "build_cost" => bc_resource_2,
                        "backlash_risk" => sbp_resource_2,
                        "EDG_data_name" => backend_data_name_2,
                        "new_resource" => is_new_resource_2,
                        "social_backlash" => social_backlash_resource_2,
                        "cap_built_stage_1" => cap_resource_2_stage_1,
                        "cap_built_stage_2" => cap_resource_2_stage_2,
                        "cap_built_stage_3" => cap_resource_2_stage_3
                    ),
                    "block_3" => Dict(
                        "name" => name_resource_3,
                        "start_capacity" => sc_resource_3,
                        "build_cost" => bc_resource_3,
                        "backlash_risk" => sbp_resource_3,
                        "EDG_data_name" => backend_data_name_3,
                        "new_resource" => is_new_resource_3,
                        "social_backlash" => social_backlash_resource_3,
                        "cap_built_stage_1" => cap_resource_3_stage_1,
                        "cap_built_stage_2" => cap_resource_3_stage_2,
                        "cap_built_stage_3" => cap_resource_3_stage_3
                    ),
                    "block_4" => Dict(
                        "name" => name_resource_4,
                        "start_capacity" => sc_resource_4,
                        "build_cost" => bc_resource_4,
                        "backlash_risk" => sbp_resource_4,
                        "EDG_data_name" => backend_data_name_4,
                        "new_resource" => is_new_resource_4,
                        "social_backlash" => social_backlash_resource_4,
                        "cap_built_stage_1" => cap_resource_4_stage_1,
                        "cap_built_stage_2" => cap_resource_4_stage_2,
                        "cap_built_stage_3" => cap_resource_4_stage_3
                    ),
                    "block_5" => Dict(
                        "name" => name_resource_5,
                        "start_capacity" => sc_resource_5,
                        "build_cost" => bc_resource_5,
                        "backlash_risk" => sbp_resource_5,
                        "EDG_data_name" => backend_data_name_5,
                        "new_resource" => is_new_resource_5,
                        "social_backlash" => social_backlash_resource_5,
                        "cap_built_stage_1" => cap_resource_5_stage_1,
                        "cap_built_stage_2" => cap_resource_5_stage_2,
                        "cap_built_stage_3" => cap_resource_5_stage_3
                    ),
                    "block_6" => Dict(
                        "name" => name_resource_6,
                        "start_capacity" => sc_resource_6,
                        "build_cost" => bc_resource_6,
                        "backlash_risk" => sbp_resource_6,
                        "EDG_data_name" => backend_data_name_6,
                        "new_resource" => is_new_resource_6,
                        "social_backlash" => social_backlash_resource_6,
                        "cap_built_stage_1" => cap_resource_6_stage_1,
                        "cap_built_stage_2" => cap_resource_6_stage_2,
                        "cap_built_stage_3" => cap_resource_6_stage_3
                    ),
                    "block_7" => Dict(
                        "name" => name_resource_7,
                        "start_capacity" => sc_resource_7,
                        "build_cost" => bc_resource_7,
                        "backlash_risk" => sbp_resource_7,
                        "EDG_data_name" => backend_data_name_7,
                        "new_resource" => is_new_resource_7,
                        "social_backlash" => social_backlash_resource_7,
                        "cap_built_stage_1" => cap_resource_7_stage_1,
                        "cap_built_stage_2" => cap_resource_7_stage_2,
                        "cap_built_stage_3" => cap_resource_7_stage_3
                    ),
                    "block_8" => Dict(
                        "name" => name_resource_8,
                        "start_capacity" => sc_resource_8,
                        "build_cost" => bc_resource_8,
                        "backlash_risk" => sbp_resource_8,
                        "EDG_data_name" => backend_data_name_8,
                        "new_resource" => is_new_resource_8,
                        "social_backlash" => social_backlash_resource_8,
                        "cap_built_stage_1" => cap_resource_8_stage_1,
                        "cap_built_stage_2" => cap_resource_8_stage_2,
                        "cap_built_stage_3" => cap_resource_8_stage_3
                    ),
                ),
                "uncertainty_parameters" => Dict(
                    "Demand_Variance" => up_demand_variance,
                    "Disaster_Probability" => up_disaster_probability,
                    "Outage_Probability" => up_outage_probability,
                    "Outage_Rate" => up_outage_rate
                ),
                "experience_rate" => experience_rate,
                "backlash_rates" => Dict(
                    "none" => br_none,
                    "low" => br_low,
                    "moderate" => br_moderate,
                    "high" => br_high
                ),
                "scoring_parameters" => Dict(
                    "Max_Points" => sp_max_points,
                    "Clean_Stage_1" => sp_clean_stage_1,
                    "Clean_Stage_2" => sp_clean_stage_2,
                    "Clean_Stage_3" => sp_clean_stage_3,
                    "Clean_Stage_4" => sp_clean_stage_4,
                    "Clean_Stage_5" => sp_clean_stage_5,
                    "Reliability" => sp_reliability
                ),
                "shaping_tokens" => Dict(
                    "resilience" => resilience,
                    "innovation_experience" => innovation_experience,
                    "innovation_clean_firm" => innovation_clean_firm,
                    "social_license" => social_license
                ),
                "reliability_scores" => Dict(
                    1 => reliability_score_stage_1,
                    2 => reliability_score_stage_2,
                    3 => reliability_score_stage_3,
                    4 => reliability_score_stage_4,
                    5 => reliability_score_stage_5
                ),
                "clean_scores" => Dict(
                    1 => clean_score_stage_1,
                    2 => clean_score_stage_2,
                    3 => clean_score_stage_3,
                    4 => clean_score_stage_4,
                    5 => clean_score_stage_5
                ),
            )

            # save setup to file
            scenario_name = split(selected_file, ".")[1]
            open(joinpath(team_path, "$(scenario_name)_stage_$(current_stage).yml"), "w") do f
                write(f, YAML.yaml(data))
            end
        end
        # update tab
        tab = "Results"
    end

    @onchange current_stage begin
        if current_stage <= length(_stages)
            year = _stages[current_stage]
            available_build_tokens = _available_build_tokens[current_stage]
        end
    end

    @onchange year begin
        if year == _stages[1]
            color_year_1 = color_select
            color_year_2 = color_default
            color_year_3 = color_default
            color_year_4 = color_default
            color_year_5 = color_default
        elseif year == _stages[2]
            color_year_1 = color_default
            color_year_2 = color_select
            color_year_3 = color_default
            color_year_4 = color_default
            color_year_5 = color_default
        elseif year == _stages[3]
            color_year_1 = color_default
            color_year_2 = color_default
            color_year_3 = color_select
            color_year_4 = color_default
            color_year_5 = color_default
        elseif year == _stages[4]
            color_year_1 = color_default
            color_year_2 = color_default
            color_year_3 = color_default
            color_year_4 = color_select
            color_year_5 = color_default
        elseif year == _stages[5]
            color_year_1 = color_default
            color_year_2 = color_default
            color_year_3 = color_default
            color_year_4 = color_default
            color_year_5 = color_select
        end
    end

    @onchange game_over begin
        # show_pannels = "display: none"
        show_game_over = "display: "
    end
end

@page("/", "app.jl.html")

end

