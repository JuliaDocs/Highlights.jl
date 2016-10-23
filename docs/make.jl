using Documenter, Highlights

# Generate demo pages.

let dir = joinpath(dirname(@__FILE__), "..", "test", "samples")
    for file in readdir(dir)
        local source = readstring(joinpath(dir, file))
        local lexer = Highlights.lexer(file)
        local def = Highlights.definition(lexer)
        local destination = joinpath(dirname(@__FILE__), "src", "demo", "lexers")
        ispath(destination) || mkpath(destination)
        open(joinpath(destination, file * ".md"), "w") do buf
            println(buf, "# ", def[:name], "\n")
            println(buf, "`$lexer` -- *", def[:description], "*", "\n")
            println(buf, "```@raw html")
            stylesheet(buf, MIME("text/html"), lexer)
            highlight(buf, MIME("text/html"), source, lexer)
            println(buf, "```")
        end
    end
    local source = readstring(joinpath(dir, "julia"))
    for theme in subtypes(Highlights.AbstractTheme)
        local destination = joinpath(dirname(@__FILE__), "src", "demo", "themes")
        ispath(destination) || mkpath(destination)
        local def = Highlights.definition(theme)
        open(joinpath(destination, string(theme) * ".md"), "w") do buf
            println(buf, "# ", def[:name], "\n")
            println(buf, "`$theme` -- *", def[:description], "*", "\n")
            println(buf, "```@raw html")
            stylesheet(buf, MIME("text/html"), Lexers.JuliaLexer, theme)
            highlight(buf, MIME("text/html"), source, Lexers.JuliaLexer, theme)
            println(buf, "```")
        end
    end
end

const LEXERS = readdir(joinpath(dirname(@__FILE__), "src", "demo", "lexers"))
const THEMES = readdir(joinpath(dirname(@__FILE__), "src", "demo", "themes"))

# Build docs.

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
