using ElectricityDecarbonizationGame
import Documenter

# Build documentation.
# ====================
Documenter.makedocs(;
    modules = [ElectricityDecarbonizationGame],
    authors = "",
    sitename = "ElectricityDecarbonizationGame",
    format = Documenter.HTML(
        canonical = "https://princetonzerolab.github.io/Path-to-Zero/stable/",
        assets = ["assets/epg_style.css"],
    ),
    pages = [
        "Welcome Page" => "index.md",
        "Getting Started" => "getting_started.md",
        "Instructions" => "instructions.md",
        "Three-stage board" => "board.md",
    ],

)

# Deploy built documentation.
# ===========================
Documenter.deploydocs(;
    repo="github.com/PrincetonZEROLab/Path-to-Zero.git",
    target = "build",
    branch = "gh-pages",
    devbranch = "main",
    devurl = "dev",
    push_preview=true,
)