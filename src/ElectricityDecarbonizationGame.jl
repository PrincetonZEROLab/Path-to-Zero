module ElectricityDecarbonizationGame

using GenieFramework
using JuMP, CSV, Random, Distributions, YAML
using HiGHS
using DataFrames
using GenieFramework
using HTTP
using PlotlyBase

include("EDG_engine.jl")

export run_simulation, advance_stage, get_traces

using PrecompileTools: @compile_workload

@compile_workload begin
    backend_data_name = ["natural_gas",
            "nuclear",
            "solar_pv",
            "distributed_solar",
            "onshore_wind",
            "offshore_wind",
            "battery",
            "clean_firm"]

        start_capacity = DataFrame(
            resource_1=10,
            resource_2=10,
            resource_3=10,
            resource_4=10,
            resource_5=10,
            resource_6=10,
            resource_7=10,
            resource_8=10
        )
        rename!(start_capacity, backend_data_name)

        build_tokens = DataFrame(
            resource_1=1,
            resource_2=1,
            resource_3=1,
            resource_4=1,
            resource_5=1,
            resource_6=1,
            resource_7=1,
            resource_8=1
        )
        rename!(build_tokens, backend_data_name)

        build_cost = DataFrame(
            resource_1=10,
            resource_2=10,
            resource_3=10,
            resource_4=10,
            resource_5=10,
            resource_6=10,
            resource_7=10,
            resource_8=10
        )
        rename!(build_cost, backend_data_name)  

        resource_params = Dict(
            "Start_Capacity" => start_capacity,
            "Build_Cost" => build_cost,
            "Build_Tokens" => build_tokens,
        )
        
        _shaping_tokens = Dict(
            "Resilience" => 1,
            "Innovation_Experience" => 1,
            "Innovation_Clean_Firm" => 1,
            "Social_License" => 1
        )

        _uncertainty_parameters = Dict(
            "Demand_Variance" => 0.00,
            "Disaster_Probability" => [0.1, 0.2, 0.3, 0.4, 0.5],
            "Outage_Probability" => 0.66,
            "Outage_Rate" => 0.5
          )

        _scoring_parameters = Dict(
            "Max_Points" => 5,
            "Clean_Stage_1" => [60, 58, 56, 53, 50],
            "Clean_Stage_2" => [70, 68, 66, 63, 60],
            "Clean_Stage_3" => [80, 78, 76, 73, 70],
            "Clean_Stage_4" => [90, 88, 86, 83, 80],
            "Clean_Stage_5" => [99.9, 99, 98, 96, 90],
            "Reliability" => [99.99, 99.5, 99.0, 98.0, 97.0]
        )

        _experience_rate = 0.025

        _backlash_risk = DataFrame(
            resource_1="low",
            resource_2="low",
            resource_3="low",
            resource_4="low",
            resource_5="low",
            resource_6="low",
            resource_7="low",
            resource_8="low"
        )
        rename!(_backlash_risk, backend_data_name)

        _backlash_rates = DataFrame(
            none=0,
            low=0.1,
            moderate=0.17,
            high=0.25
        )
        run_simulation(1, 2030, resource_params, _scoring_parameters)
        advance_stage(1, 2030, resource_params, _shaping_tokens, _uncertainty_parameters, _scoring_parameters, _experience_rate, _backlash_risk, _backlash_rates)
end

end # module ElectricityDecarbonizationGame
