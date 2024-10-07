# Getting Started 

## How to Run Path To Zero on GitHub Codespaces (GitHub account required)
- Navigate to the following [GitHub page](https://github.com/PrincetonZEROLab/Path-to-Zero) and click the "Code" button.
- Click the "Codespaces" tab.
- Click the "Create codespace on main" button.
- Once the codespace is created, you can start the game by running the following command in the command line:
```bash
bash run_game.sh
```
- Navigate to `localhost:8000` in your web browser to access the game, or click on the URL that appears in the terminal after "Web Server starting at".

Note: All personal GitHub accounts are limited to 120 hours of compute time and 15GB of storage per month. You can learn more about the limitations [here](https://docs.github.com/en/billing/managing-billing-for-github-codespaces/about-billing-for-github-codespaces) and [here](https://docs.github.com/en/codespaces/overview).

## How to Install Path To Zero (local installation)
- **Install Julia**: We recommend following the [Julia installation guide](https://julialang.org/downloads/).

- **Clone the repository**: You can clone the repository by typing the following command in your command line:
```julia
git clone https://github.com/PrincetonZEROLab/Path-to-Zero.git
cd Path-to-Zero
```

- **Install the game**: You can install the game by typing the following command in your command line:
```julia
julia -e 'import Pkg; Pkg.activate("."); Pkg.instantiate()'
```

- **Run the game**: You can run the game by typing the following command in your command line (Linux/MacOS)
```bash
bash run_game.sh
```
or (Windows)
```julia
julia --project -q -i -e "using Pkg; Pkg.precompile(); using GenieFramework; Genie.loadapp(); up();" 
```