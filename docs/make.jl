using Documenter, Highlights

makedocs(
    format = :html,
    modules = [Highlights],
    sitename = "Highlights.jl",
    authors = "Michael Hatherly",
    pages = [
        "Home" => "index.md",
        "Manual" => [
            "man/guide.md",
            "man/theme.md",
            "man/lexer.md",
        ],
        "Library" => [
            "lib/public.md",
            "lib/internals.md",
        ],
    ],
)

deploydocs(
    repo = "github.com/JuliaDocs/Highlights.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
)
