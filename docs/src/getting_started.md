# Getting Started 

## How to Run Path-to-Zero

### GitHub Codespaces
!!! warning "Note"
    GitHub account required, no Julia installation required

- Navigate to the following [GitHub page](https://github.com/PrincetonZEROLab/Path-to-Zero) and click the "Code" button.
- Click the "Codespaces" tab.
- Click the "Create codespace on main" button.
- Once the codespace is created, you can start the game by running the following command in the command line:
```bash
bash run_game.sh
```
or 
```bash
make start_game
```

- Navigate to `localhost:8000` in your web browser to access the game, or use ctrl+click (or cmd+click on Mac) on the URL that appears in the terminal.

!!! tip "Tip: Prebuilds"
    You can configure and set up prebuilds for your own fork of the game to speed up the process of launching the codespace. For more information, see the [GitHub documentation](https://docs.github.com/en/codespaces/prebuilding-your-codespaces/configuring-prebuilds).

!!! note "Note: Free compute time"
    All personal GitHub accounts are limited to 120 hours of compute time and 15GB of storage per month. You can learn more about these limitations [here](https://docs.github.com/en/billing/managing-billing-for-github-codespaces/about-billing-for-github-codespaces) and [here](https://docs.github.com/en/codespaces/overview).

!!! danger "Spending limits and stopping codespaces"
    By default, all accounts have a GitHub Codespaces spending limit of \$0 USD, which prevents users from creating or opening codespaces once their personal compute time limits are exceeded. However, if you have set up spending limits, please remember to stop the codespace when you are done playing the game to avoid incurring charges. See [here](https://docs.github.com/en/billing/managing-billing-for-your-products/managing-billing-for-github-codespaces/managing-the-spending-limit-for-github-codespaces#managing-usage-and-spending-limit-email-notifications) for more information.

### Local Installation
- **Install Julia**: We recommend following the [Julia installation guide](https://julialang.org/downloads/).

- **Clone the [repository](https://github.com/PrincetonZEROLab/Path-to-Zero)**: You can clone the repository by typing the following command in your command line:
```julia
git clone https://github.com/PrincetonZEROLab/Path-to-Zero.git
cd Path-to-Zero
```

!!! note "Note"
    If [Git](https://git-scm.com/) is not installed, you can download the repository as a zip file by clicking the "Code" button on the GitHub page and then clicking the "Download ZIP" button.

- **Install the game**: To install the game, type the following command in your command line:
```julia
julia -e 'import Pkg; Pkg.activate("."); Pkg.instantiate()'
```

- **Run the game**: To run the game, use the following commands:
On **Linux/MacOS**:
```bash
bash run_game.sh
```
On **Windows**:
```julia
julia --project -q -i -e "using Pkg; Pkg.precompile(); using GenieFramework; Genie.loadapp(); up();" 
```

- **Launch the game**: Open your web browser and go to `http://localhost:8000/` to access the game.

## How to Play Path-to-Zero
For detailed game instructions, please refer to the [Game play instructions](@ref) section of the manual.