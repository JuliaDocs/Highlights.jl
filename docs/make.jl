using Documenter, Highlights
using InteractiveUtils

# Generate demo pages.

let dir = joinpath(dirname(@__FILE__), "..", "test", "samples")
    destination = joinpath(dirname(@__FILE__), "src", "demo", "lexers")
    ispath(destination) && rm(destination, recursive = true)
    mkpath(destination)
    for file in readdir(dir)
        source = read(joinpath(dir, file), String)
        lexer = Highlights.lexer(file)
        def = Highlights.Compiler.metadata(lexer)
        open(joinpath(destination, file * ".md"), "w") do buf
            println(buf, "# ", def.name, "\n")
            println(buf, "`$lexer` -- *", def.description, "*", "\n")
            println(buf, "```@raw html")
            stylesheet(buf, MIME("text/html"))
            highlight(buf, MIME("text/html"), source, lexer)
            println(buf, "```")
        end
    end
    source = read(joinpath(dir, "julia"), String)
    destination = joinpath(dirname(@__FILE__), "src", "demo", "themes")
    ispath(destination) && rm(destination, recursive = true)
    mkpath(destination)
    for theme in subtypes(Highlights.AbstractTheme)
        def = Highlights.Themes.metadata(theme)
        open(joinpath(destination, replace(lowercase(def[:name]), " " => "-") * ".md"), "w") do buf
            println(buf, "# ", def[:name], "\n")
            println(buf, "`$theme` -- *", def[:description], "*", "\n")
            println(buf, "```@raw html")
            stylesheet(buf, MIME("text/html"), theme)
            highlight(buf, MIME("text/html"), source, Lexers.JuliaLexer, theme)
            println(buf, "```")
        end
    end
end

const LEXERS = readdir(joinpath(dirname(@__FILE__), "src", "demo", "lexers"))
const THEMES = readdir(joinpath(dirname(@__FILE__), "src", "demo", "themes"))

# Build docs.

makedocs(
    format = Documenter.HTML(),
    modules = [Highlights],
    sitename = "Highlights.jl",
    authors = "Michael Hatherly",
    pages = [
        "Home" => "index.md",
        "Manual" => [
            "man/guide.md",
            "man/theme.md",
            "man/lexer.md",
            "man/formatting.md",
        ],
        "Demos" => [
            hide("demo/lexers.md", ["demo/lexers/$f" for f in LEXERS])
            hide("demo/themes.md", ["demo/themes/$f" for f in THEMES])
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
