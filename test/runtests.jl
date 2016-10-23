using Highlights

if VERSION >= v"0.5.0-dev+7720"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end


#
# Utilities.
#

const __DIR__ = dirname(@__FILE__)

const TOKEN_NAME_CACHE = Dict()

function tokentest(lexer, source, expects...)
    local tokens = Highlights.Compiler.lex(source, lexer).tokens
    local lookup::Dict = get!(TOKEN_NAME_CACHE, lexer) do
        Dict([(hash(s), s) for s in Themes.tokens(lexer)])
    end
    @test length(tokens) == length(expects)
    @test join([s for (n, s) in expects]) == source
    for (token, (name, str)) in zip(tokens, expects)
        @test lookup[token.value] == name
        @test SubString(source, token.first, token.last) == str
    end
end

function print_all(lexer, file)
    local source = readstring(joinpath(__DIR__, "samples", file))
    local buffer = IOBuffer()
    for m in ["html", "latex"]
        mime = MIME("text/$m")
        for theme in subtypes(Themes.AbstractTheme)
            stylesheet(buffer, mime, Lexers.JuliaLexer, theme)
            highlight(buffer, mime, source, Lexers.JuliaLexer, theme)
        end
    end
    return buffer
end


#
# Testsets.
#

@testset "Highlights" begin
    @testset "Lexers" begin
        @testset for file in readdir(joinpath(__DIR__, "lexers"))
            include("lexers/$file")
        end
    end
end
