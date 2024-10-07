var documenterSearchIndex = {"docs":
[{"location":"board/","page":"Three-stage board","title":"Three-stage board","text":"(Image: png)","category":"page"},{"location":"getting_started/#Getting-Started","page":"Getting Started","title":"Getting Started","text":"","category":"section"},{"location":"getting_started/#How-to-Run-Path-to-Zero","page":"Getting Started","title":"How to Run Path-to-Zero","text":"","category":"section"},{"location":"getting_started/#GitHub-Codespaces","page":"Getting Started","title":"GitHub Codespaces","text":"","category":"section"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"warning: Note\nGitHub account required, no Julia installation required","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"Navigate to the following GitHub page and click the \"Code\" button.\nClick the \"Codespaces\" tab.\nClick the \"Create codespace on main\" button.\nOnce the codespace is created, you can start the game by running the following command in the command line:","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"bash run_game.sh","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"or ","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"make start_game","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"Navigate to localhost:8000 in your web browser to access the game, or use ctrl+click (or cmd+click on Mac) on the URL that appears in the terminal.","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"tip: Tip: Prebuilds\nYou can configure and set up prebuilds for your own fork of the game to speed up the process of launching the codespace. For more information, see the GitHub documentation.","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"note: Note: Free compute time\nAll personal GitHub accounts are limited to 120 hours of compute time and 15GB of storage per month. You can learn more about these limitations here and here.","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"danger: Spending limits and stopping codespaces\nBy default, all accounts have a GitHub Codespaces spending limit of $0 USD, which prevents users from creating or opening codespaces once their personal compute time limits are exceeded. However, if you have set up spending limits, please remember to stop the codespace when you are done playing the game to avoid incurring charges. See here for more information.","category":"page"},{"location":"getting_started/#Local-Installation-(No-GitHub-account-required)","page":"Getting Started","title":"Local Installation (No GitHub account required)","text":"","category":"section"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"Install Julia: We recommend following the Julia installation guide.\nClone the repository: You can clone the repository by typing the following command in your command line:","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"git clone https://github.com/PrincetonZEROLab/Path-to-Zero.git\ncd Path-to-Zero","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"note: Note\nIf Git is not installed, you can download the repository as a zip file by clicking the \"Code\" button on the GitHub page and then clicking the \"Download ZIP\" button.","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"Install the game: To install the game, type the following command in your command line:","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"julia -e 'import Pkg; Pkg.activate(\".\"); Pkg.instantiate()'","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"Run the game: To run the game, use the following commands:","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"On Linux/MacOS:","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"bash run_game.sh","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"On Windows:","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"julia --project -q -i -e \"using Pkg; Pkg.precompile(); using GenieFramework; Genie.loadapp(); up();\" ","category":"page"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"Launch the game: Open your web browser and go to http://localhost:8000/ to access the game.","category":"page"},{"location":"getting_started/#How-to-Play-Path-to-Zero","page":"Getting Started","title":"How to Play Path-to-Zero","text":"","category":"section"},{"location":"getting_started/","page":"Getting Started","title":"Getting Started","text":"For detailed game instructions, please refer to the Game play instructions section of the manual.","category":"page"},{"location":"instructions/#Game-play-instructions","page":"Instructions","title":"Game play instructions","text":"","category":"section"},{"location":"instructions/#Game-Objective","page":"Instructions","title":"Game Objective","text":"","category":"section"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"The objective is to achieve the highest cumulative score at the end of Stage 5. The total score is the sum of scores earned across three game objectives:","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"Reliability: each Stage, you earn up to 5 points depending on the percentage of annual electricity demand successfully met by your resource portfolio after resolving the simulation phase (including the impacts of Demand Shocks and possible Climate Disasters). Note that Demand grows with each Stage (see Peak/Average Demand under the Game Stages).\nClean Energy: each Stage, you earn up to 5 points depending on the percentage of annual electricity demand generated by non-emitting (clean) resources after resolving the simulation phase (including the impacts of Demand Shocks and possible Climate Disasters). The share of clean energy is calculated as the sum of generation excluding emitting resources and energy storage divided by the total demand served. A higher share of non-emitting generation is required as the Stages progress.\nAffordability: at the end of Stage 5, you earn 3 points per Budget token remaining. Budget tokens can be used throughout Stages to purchase additional Build tokens or Shaping tokens, but expending Budget tokens lowers your final score, so spend wisely. ","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"tip: Maximum Score\nNote that a maximum score of 65 points is possible: 25 points for Reliability, 25 points for Clean Energy, and 15 points for Affordability.","category":"page"},{"location":"instructions/#Game-Stages","page":"Instructions","title":"Game Stages","text":"","category":"section"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"The game proceeds through four Stages, representing a given planning period, where your goal is to build and maintain a sufficient portfolio of resources (generation & storage) to meet expected demand while meeting reliability and clean energy goals. ","category":"page"},{"location":"instructions/#Uncertainty","page":"Instructions","title":"Uncertainty","text":"","category":"section"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"There are four types of uncertainty to consider in your planning:","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"Demand Shocks: Demand in each Stage is uncertain and will differ from the expected values by a constant percentage throughout the year. Demand may be either lower or higher than expected.\nExperience Curves: Expending Build tokens to construct a new resource will drive down the cost of that resource in the next Stage by approximately 5% per token, but the exact pace of cost declines is uncertain. \nSocial Backlash: Expending Build tokens to construct or maintain a resource risks triggering Social Backlash, which prevents that resource from being built or maintained in the next Stage. Each resource has a different Backlash Risk per Build token. The precise risk of Social Backlash is uncertain, but each resource type has a different relative risk: Low, Medium or High..\nClimate Disasters: Each Stage, there is a chance of a climate-related weather disaster (flood, fires, hurricane, etc.). If a disaster occurs, each resource type faces a probability of forced outages knocking offline 50% of installed capacity for two weeks. Disaster risk increases as the Stages progress.","category":"page"},{"location":"instructions/#Phases","page":"Instructions","title":"Phases","text":"","category":"section"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"Each Stage proceeds through four phases: ","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"The Resource Phase, where resources are built and maintained; \nThe Shaping Phase, where you choose to expend any available Shaping tokens to manage uncertainty; \nThe Simulation Phase, where a year of electricity demand is simulated and your resource portfolio is used to meet demand at least cost and your Reliability and Clean Energy scores are reported, taking into account the impact of Demand Shocks and Climate Disasters; \nThe Resolution Phase, where cost reductions from Experience Curves are calculated and Social Backlash risks are resolved and the game board is updated for the next Stage. ","category":"page"},{"location":"instructions/#1.-Resource-Phase","page":"Instructions","title":"1. Resource Phase","text":"","category":"section"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"Each Stage, you have a specified number of Build tokens available. Additional Build tokens may be purchased by expending Budget tokens (two Build tokens per Budget token). Build tokens cannot be saved between game rounds and any unspent Build tokens will be lost at the end of the Stage.","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"Each resource has a specified maintenance or construction cost which denotes how many gigawatts (GW) of that resource can be purchased for each Build token.","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"Existing resources (marked with orange boxes in the GUI): in each Stage, you must expend sufficient Build tokens to maintain current capacity of existing resources or capacity for that resource will retire. Each existing resource specifies how many GW can be maintained per Build token expended. Any capacity in excess of the GWs maintained by expending Build tokens will permanently retire (close) and will be unavailable to meet demand during that Stage (e.g. capacity is retired prior to the Simulation phase). Once retired, capacity for that resource is permanently reduced for all subsequent stages. No new capacity can be added for existing resources. The cost of maintaining existing resources does not decline due to Experience Curves.","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"note: Example\nYou have 60 GW of Existing Fossil at the start of Stage 1. The game setup specifies that 20 GW can be maintained for each Build token. You choose to expend 2 Build tokens to maintain 40 GW of Existing Fossil and let 20 GW of Existing Fossil retire. 40 GW of Existing Fossil will be available to meet demand during the Stage 1 Simulation Phase and you will begin Stage 2 with 40 GW of Existing Fossil capacity. ","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"warning: Special rule\nExisting nuclear power plants have to be refurbished and relicensed to expend their lifetime during Stage 2, which doubles the number of Build tokens required to maintain their capacity during Stage 2 only. ","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"Social Backlash: Expending Build tokens to maintain existing resources risks triggering Social Backlash. If Social Backlash is triggered for an existing resource at the end of Stage 1-Stage 4, then no Build tokens can be expended to maintain the existing resource in the next Stage. As a result, all existing capacity for that resource will be forced to retire before the Simulation phase in that Stage. The precise risk of Social Backlash is uncertain, but each resource type has a different relative risk: Low, Medium or High.","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"note: Example\nAfter expending 2 Build tokens to maintain 40 GW of Existing Fossil in Stage 1, a Social Backlash is triggered for Existing Fossil resources during the Stage 1 Simulation Phase. During Stage 2, no Build tokens can be expended on Existing Fossil and all 40 GW consequently will retire before the Stage 2 Simulation stage.","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"New resources: Build tokens can also be used to build new resources. Each resource specifies how many GW are built per Build token. Once built in one Stage, capacity from these resources is available to meet demand during the current Stage’s Simulation Phase and in all subsequent Stages. You do not need to expend Build tokens to maintain capacity built in a previous Stage. ","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"warning: Special rule\nClean Firm Resource is unavailable in Stage 1. Build tokens cannot be expended to construct Clean Firm Resource capacity unless a Shaping token is expended to select the Demonstration Program action. If the Demonstration Program action is taken during any Shaping Phase, the Clean Firm Resource becomes available to build in all subsequent Stages.  Note that the Clean Firm Resource represents a generic advanced technology that is fully dispatchable and can meet demand at any point during the year, such as advanced geothermal, advanced nuclear, fusion, Allam cycle gas combustion with carbon capture, or hydrogen combustion.","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"warning: Special rule\nBattery Energy Storage does not produce energy, but rather charges when energy is abundant and discharges when energy is more valuable. For each GW of Battery Energy Storage built, you can store up to 4 gigawatt-hours (GWh) of energy. In other words, it would take four hours to fully charge a battery and four hours to fully discharge a battery (if charging and discharging at full power capacity).  Battery Energy Storage has an 85% efficiency, so for every 1 GWh of energy consumed by the battery for charging, only 0.85 GWh can be discharged. ","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"Experience Curves: Building new resources will drive Experience Curves which reduce the cost of constructing the resource in subsequent stages by approximately 5% per Build token spent, but the exact pace is uncertain and resolved during the Resolution phase.  Note: reduced cost of construction is expressed as an increase in GW of new capacity constructed per Build token.","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"Social Backlash: Expending Build tokens to construct new resources also risks triggering Social Backlash. If Social Backlash is triggered for a new resource at the end of Stage 1-Stage 4, then no Build tokens can be expended to construct more of that new resource in the next Stage. Existing capacity for that resource will still be available in the next Stage. The precise risk of Social Backlash is uncertain, but each resource type has a different relative risk: Low, Medium or High. ","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"note: Example\nAt the start of Stage 1, the game setup specifies you may construct 10 GW of Onshore Wind per Build token. In Stage 1, you choose to expend 4 Build tokens to construct 40 GW of Onshore Wind, which is used to meet demand during the Stage 1 Simulation Phase. During the Resolution Phase, the cost of Onshore Wind improves by 20% and no Social Backlash is triggered. During Stage 2, you can now build 12 GW per Build token. During Stage 2, you expend 4 more Build tokens to build another 48 GW of Onshore Wind, increasing the total available capacity to 88 GW during the Stage 2 Simulation Phase. During the Resolution Phase, a Social Backlash is triggered for Onshore Wind. As a result, you may not expend any Build tokens to construct additional Onshore Wind capacity during Stage 3. The 88 GW of capacity constructed in Stages 1 and 2 is still available to meet demand during the Stage 3 Simulation Phase.","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"Testing your portfolio: At any point during the Resource Phase, you have access to the Dispatch Simulator, which you can use to test a potential resource portfolio. Simply enter the capacity of each resource type and simulate a year of optimized operation to meet forecasted demand for the current Stage. By testing different portfolios, you can build intuition about the profile of annual demand and wind or solar resource variability, what mix of resources is likely to meet expected demand, and estimate what the likely reliability and clean energy scores would be for that portfolio. Note however that the Dispatch Simulator does not account for any uncertainty, including Demand Shocks that can cause actual demand to differ from the forecasted demand by a constant percentage throughout the year and the potential for Climate Shocks to reduce available capacity by causing forced outages for each resource. You will have to use your own intuition to develop a portfolio that is robust to these uncertainties.","category":"page"},{"location":"instructions/#Shaping-Phase","page":"Instructions","title":"Shaping Phase","text":"","category":"section"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"Each Stage, you may expend Shaping tokens to take one of four Shaping Actions which help manage the uncertainty faced during the game. You begin Stage 1 with 2 Shaping tokens, and one additional Shaping token can be purchased in any Stage by expending a Budget token. Once you allocate a Shaping token to choose a Shaping Action, you cannot change this selection later in the game (so choose carefully). You can only allocate one Shaping token per Shaping Action. You will be asked to confirm your selection of Shaping Actions before your choice is finalized. ","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"The four Shaping Actions available are:","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"Accelerated Innovation: Expending a Shaping token on this action doubles the pace of cost reductions as each technology is deployed. The expected cost reduction from Experience Curves increases to 10% per Build token, though the actual pace of reduction remains uncertain.\nDemonstration Program: Expending a Shaping token on this action unlocks the Clean Firm Resource. In any subsequent Stage after this Shaping Action is taken, Build tokens can be expended to construct Clean Firm Resource capacity. Note that you cannot expend any Build tokens to build the Clean Firm Resource during the same Stage that you take this action.\nBenefits Sharing: Expending a Shaping token on this action reduces by half the probability of Social Backlash as each technology is deployed. Note that this reduction in Social Backlash risk applies to all Resources.\nClimate Resilience: Expending a Shaping token on this action reduces by half the probability of generator forced outages when a Climate Disaster is experienced. Note that this reduction in forced outage risk applies to all Resources and that this action does not reduce the probability of a Climate Disaster occuring.","category":"page"},{"location":"instructions/#Simulation-Phase","page":"Instructions","title":"Simulation Phase","text":"","category":"section"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"After completing the Build and Shaping phases, the game will simulate an entire year of operations of your portfolio of resources. ","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"During the Simulation Phase, a random Demand Shock will increase or decrease demand by a constant percentage during each hour. ","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"For each Stage, there is also a risk of a Climate Disaster occuring. This risk increases as each Stage progresses (the risk of Climate Disaster is higher in Stage 3 than in Stage 2 and higher in Stage 2 than in Stage 1), though the precise probability of a Climate Disaster is unknown. If a Climate Disaster occurs, it will occur during a random two week period during the year, and for each resource, there is a probability that 50% of the resource’s installed capacity is unavailable during that period. A separate random variable will be drawn for each resource type. ","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"After resolving the Demand Shock and the effect of any Climate Disaster (should one occur) on the availability of each resource, the game will optimize operations of all resources to minimize the overall cost of meeting demand, including penalties for not serving demand or meeting the targeted clean energy share for the Stage. The results of this optimal dispatch simulation will then be used to calculate and report the Reliability and Clean Energy scores for the Stage.","category":"page"},{"location":"instructions/#Resolution-Phase","page":"Instructions","title":"Resolution Phase","text":"","category":"section"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"During this phase, the game calculates the reduction in cost for each resource due to Experience Curves and determines whether Social Backlash is triggered for any resource. ","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"Experience Curves: Building new resources will drive Experience Curves which reduce the cost of constructing the resource in subsequent stages by approximately 5% per Build token spent, but the exact pace is uncertain and resolved during this phase. Note: reduced cost of construction is expressed as an increase in GW of new capacity constructed per Build token. Expending ","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"Social Backlash: Expending Build tokens to construct new resources also risks triggering Social Backlash. If Social Backlash is triggered for a new resource at the end of Stage 1 or Stage 2, then no Build tokens can be expended to construct more of that new resource in the next Stage. Existing capacity for that resource will still be available in the next Stage. The precise risk of Social Backlash is uncertain and resolved during this stage. Each resource type has a different relative risk: Low, Medium or High. ","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"After calculating the effect of Experience Curves or Social Backlash, the game board is updated and the next Stage commences.","category":"page"},{"location":"instructions/#Game-Board-Settings","page":"Instructions","title":"Game Board Settings","text":"","category":"section"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"The following parameters are specified on the game board and known by the players:","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"Starting capacity: the starting capacity in GW of Existing Fossil and Existing Nuclear (if applicable) resources must be specified.","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"Maintenance and construction costs: the cost of maintaining existing resources or constructing new resources at the start of Stage 1 must be specified. This is expressed by entering the GW maintained/constructed per Build token.","category":"page"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"Backlash risk: The risk of Social Backlash for each resource type must be designated as High, Medium, or Low.","category":"page"},{"location":"instructions/#Behind-the-scenes-settings-(for-game-masters)","page":"Instructions","title":"Behind the scenes settings (for game masters)","text":"","category":"section"},{"location":"instructions/","page":"Instructions","title":"Instructions","text":"<details id=\"myDetails\" style=\"padding: 5px; background-color: #f0f0f0; border-radius: 5px;\">\n<summary id=\"mySummary\" style=\"background-color: #969393; color:white; padding: 5px; border-radius: 5px; list-style-type: '⬇ '\">Click to expand/collapse</summary>\n\n<p style=\"margin-top: 0.5em;\">The following parameters are specified which determine the behavior of the Simulation and Resolution Phases and are unknown to the players:</p>\n\n<p><strong>Demand variance</strong>: The Demand Shock in each Stage is calculated based on a normal distribution with a mean of 0 and a standard deviation equal to the demand variance parameter, specified in percent.</p>\n\n<p><strong>Social Backlash rates</strong>: For each Build token expended on a given resource, a discrete random number is generated from a Bernoulli distribution with a probability equal to the specified Social Backlash rate parameters. If the result is a value of 1 in any of these Bernoulli draws, a Social Backlash occurs for that resource. The probability must be set for each of the Low, Medium, and High risk resource categories.</p>\n\n<p><strong>Climate Disaster probability</strong>: In each Stage, a discrete random number is generated from a Bernoulli distribution with a probability equal to the specified Climate Disaster probability. If the result is a value of 1 from this Bernoulli draw, a Climate Disaster occurs during this Stage. A two week period out of the year is then selected at random and the Climate Disaster occurs during this period.</p>\n\n<p><strong>Forced Outage rate</strong>: If a Climate Disaster occurs, a discrete random number is generated for each Resource type from a Bernoulli distribution with a probability equal to the specified Forced Outage rate. If the result is a value of 1 for each of these Bernoulli draws, then 50% of the installed capacity of that Resource type is unavailable during the two weeks that the Climate Disaster occurs.</p>\n\n<div class=\"admonition note\" style=\"margin-top: 10px; padding: 5px; background-color: #f0f0f0; border-radius: 5px;\">\n    <p class=\"admonition-title\">NOTE TO GAME MASTERS</p>\n    <p>Each of these parameters can be adjusted in the files located in the <a href=\"https://github.com/PrincetonZEROLab/Path-to-Zero/tree/main/game_setup\">game_setup</a> directory.</p>\n</div>\n\n</details>\n\n<script>\n  const details = document.getElementById('myDetails');\n  const summary = document.getElementById('mySummary');\n\n  details.addEventListener('toggle', function() {\n    if (details.open) {\n      summary.style.listStyleType = \"'⬆ '\";\n    } else {\n      summary.style.listStyleType = \"'⬇ '\";\n    }\n  });\n</script>","category":"page"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"CurrentModule = ElectricityDecarbonizationGame","category":"page"},{"location":"#Path-To-Zero","page":"Welcome Page","title":"Path To Zero","text":"","category":"section"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"Welcome to the Path To Zero documentation!","category":"page"},{"location":"#What-is-Path-To-Zero?","page":"Welcome Page","title":"What is Path To Zero?","text":"","category":"section"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"Path To Zero is a multi-stage planning under deep uncertainy strategy game designed to help players understand the challenges of decarbonizing the electricity sector. The objective of the game is to develop a portfolio of resources that can meet the demand at the lowest cost while also achieving stringent environmental goals. ","category":"page"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"The game simulates electricity system operations, allowing players to test out their strategies, build intuition about how power systems operate, and develop a plan to create a portfolio of resources that meets both their reliability and clean energy goals, which are two of the three objectives for which they are scored in the game.","category":"page"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"tip: Credits\nThe game was created and designed by Jesse D. Jenkins and developed by the Princeton ZERO Lab and the Princeton RSE Group at Princeton University.","category":"page"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"note: Design\nThe backend is developed in Julia and JuMP, while the frontend is built using the GenieFramework.","category":"page"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"<p style=\"text-align:center;\">\n  <img src=\"assets/julialogo.svg\" width=\"100\" />\n  <img style=\"padding-left: 20px;\" src=\"assets/jumplogo.svg\" width=\"100\" /> \n  <img style=\"padding-left: 20px;\" src=\"assets/genielogo.svg\" width=\"80\" />\n</p>","category":"page"},{"location":"#Software-Manual","page":"Welcome Page","title":"Software Manual","text":"","category":"section"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"Pages = [\n    \"getting_started.md\",\n    \"board.md\",\n    \"instructions.md\"\n]\nDepth = 2","category":"page"}]
}
