# Path To Zero
## The Electricity Decarbonization Game

Path to Zero is a multi-stage planning under deep uncertainy strategy game designed to help players understand the challenges of decarbonizing the electricity sector. The purpose of the game is to develop a portfolio of resources that will meet the demand at the lowest cost while also achieving stringent environmental goals. 

The game involves a simulation of electricity system operations (developed in Julia and JuM), which helps players test out their strategies, build intuition about how power systems operation, and develop a plan to build a portfolio of resources that meets their reliability and clean energy goals, which are two of the three objectives for which they are scored in the game.

## How to Play Path To Zero
Please see the [instructions](https://princetonzerolab.github.io/Path-to-Zero/stable/instructions/) for how to play the game.

## How to Run Path To Zero on GitHub Codespaces (GitHub account required)
1. Navigate to the following [GitHub page](https://github.com/PrincetonZEROLab/Path-to-Zero) and click the "Code" button.
2. Click the "Codespaces" tab.
3. Click the "Create codespace on main" button.
4. Once the codespace is created, you can start the game by running the following command in the command line:
```bash
bash run_game.sh
```
5. Navigate to `localhost:8000` in your web browser to access the game, or click on the URL that appears in the terminal after "Web Server starting at".

Note: All personal GitHub accounts are limited to 120 hours of compute time and 15GB of storage per month. You can learn more about the limitations [here](https://docs.github.com/en/billing/managing-billing-for-github-codespaces/about-billing-for-github-codespaces) and [here](https://docs.github.com/en/codespaces/overview).

## How to Install Path To Zero (local installation)
1. **Install Julia**: We recommend following the [Julia installation guide](https://julialang.org/downloads/).

2. **Clone the repository**: You can clone the repository by typing the following command in your command line:
```julia
git clone https://github.com/PrincetonZEROLab/Path-to-Zero.git
cd Path-to-Zero
```

3. **Install the game**: You can install the game by typing the following command in your command line:
```julia
julia -e 'import Pkg; Pkg.activate("."); Pkg.instantiate()'
```

4. **Run the game**: You can run the game by typing the following command in your command line (Linux/MacOS)
```bash
bash run_game.sh
```
or (Windows)
```julia
julia --project -q -i -e "using Pkg; Pkg.precompile(); using GenieFramework; Genie.loadapp(); up();" 
```

5. **Access the game**: You can access the game by navigating to `localhost:8000` in your web browser.

![png](./docs/assets/EDG_board.svg)