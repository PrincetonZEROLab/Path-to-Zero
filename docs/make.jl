using ElectricityDecarbonizationGame
using Documenter

DocMeta.setdocmeta!(ElectricityDecarbonizationGame, :DocTestSetup, :(using ElectricityDecarbonizationGame); recursive = true)

# Build documentation.
# ====================
makedocs(;
    modules = [ElectricityDecarbonizationGame],
    authors = "",
    sitename = "ElectricityDecarbonizationGame",
    format = Documenter.HTML(
        canonical = "https://princetonzerolab.github.io/Path-to-Zero/stable/",
    ),
    pages = [
        "Home" => "index.md",
        "Instructions" => "instructions.md",
    ],
)

# Deploy built documentation.
# ===========================
deploydocs(;
    repo="github.com/PrincetonZEROLab/Path-to-Zero.git",
    target = "build",
    branch = "gh-pages",
    devbranch = "main",
    devurl = "dev",
    push_preview=true,
)