using Documenter, Highlights

# Generate demo pages.

let dir = joinpath(dirname(@__FILE__), "..", "test", "samples")
    for file in readdir(dir)
        source = readstring(joinpath(dir, file))
        lexer = Highlights.lexer(file)
        def = Highlights.definition(lexer)
        destination = joinpath(dirname(@__FILE__), "src", "demo", "lexers")
        ispath(destination) || mkpath(destination)
        open(joinpath(destination, file * ".md"), "w") do buf
            println(buf, "# ", def[:name], "\n")
            println(buf, "`$lexer` -- *", def[:description], "*", )
            println(buf, "```@raw html")
            stylesheet(buf, MIME("text/html"), lexer)
            highlight(buf, MIME("text/html"), source, lexer)
            println(buf, "```")
        end
    end
end

const LEXERS = readdir(joinpath(dirname(@__FILE__), "src", "demo", "lexers"))

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
