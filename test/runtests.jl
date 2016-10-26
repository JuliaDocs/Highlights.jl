using Highlights, Compat

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

function tokentest(lexer, source, expects...)
    local tokens = Highlights.Compiler.lex(source, lexer).tokens
    @test length(tokens) == length(expects)
    @test join([s for (n, s) in expects]) == source
    for (token, (name, str)) in zip(tokens, expects)
        @test token.value == name
        @test SubString(source, token.first, token.last) == str
    end
end

function print_all(lexer, file)
    local source = readstring(joinpath(__DIR__, "samples", file))
    local buffer = IOBuffer()
    for m in ["html", "latex"]
        mime = MIME("text/$m")
        for theme in subtypes(Themes.AbstractTheme)
            stylesheet(buffer, mime, theme)
            highlight(buffer, mime, source, Lexers.JuliaLexer, theme)
        end
    end
    return buffer
end

#
# Setup.
#

using Highlights.Tokens

@tokengroup CustomTokens [__a, __b, __c]

# Error reporting for broken lexers.
abstract BrokenLexer <: Highlights.AbstractLexer
Highlights.definition(::Type{BrokenLexer}) = Dict(
    :tokens => Dict(:root => [(r"\w+", TEXT, (:b, :a))], :a => [], :b => []),
)

# Lexer inheritance.
abstract ParentLexer <: Highlights.AbstractLexer
abstract ChildLexer <: ParentLexer
Highlights.definition(::Type{ParentLexer}) = Dict(
    :tokens => Dict(:root => [(r"#.*$"m, COMMENT)])
)
Highlights.definition(::Type{ChildLexer}) = Dict(
    :tokens => Dict(:root => [:__inherit__, (r"\d+", NUMBER), (r".", TEXT)])
)

# Lexer self-reference using `:__this__`.
abstract SelfLexer <: Highlights.AbstractLexer
Highlights.definition(::Type{SelfLexer}) = Dict(
    :tokens => Dict(
        :root => [
            (r"(#)( )(.+)(;)$"m, (COMMENT, WHITESPACE, :__this__, PUNCTUATION)),
            (r"\d+", NUMBER),
            (r"\w+", NAME),
            (r" ", WHITESPACE),
        ],
    ),
)

#
# Testsets.
#

@testset "Highlights" begin
    @testset "Tokens" begin
        @test string(__a) == "<__a>"
        @test string(__b) == "<__b>"
        @test string(__c) == "<__c>"
        let f = getfield(Highlights.Tokens, Symbol("@tokengroup"))
            @test_throws ErrorException f(:FAILS, :[a.b, c.d])
        end
    end
    @testset "Lexers" begin
        @testset for file in readdir(joinpath(__DIR__, "lexers"))
            include("lexers/$file")
        end
        @testset "Self-referencing" begin
            tokentest(
                SelfLexer,
                "# word;",
                COMMENT => "#",
                WHITESPACE => " ",
                NAME => "word",
                PUNCTUATION => ";",
            )
            tokentest(
                SelfLexer,
                "# 1 word;",
                COMMENT => "#",
                WHITESPACE => " ",
                NUMBER => "1",
                WHITESPACE => " ",
                NAME => "word",
                PUNCTUATION => ";",
            )
        end
        @testset "Inheritance" begin
            tokentest(
                ParentLexer,
                "# ...",
                COMMENT => "# ...",
            )
            tokentest(
                ParentLexer,
                "1 # ...",
                ERROR => "1",
                ERROR => " ",
                COMMENT => "# ...",
            )
            tokentest(
                ChildLexer,
                "1 # ...",
                NUMBER => "1",
                TEXT => " ",
                COMMENT => "# ...",
            )
        end
        @testset "Errors" begin
            tokentest(BrokenLexer, " ", ERROR => " ")
        end
    end
    @testset "Themes" begin
        let s = Themes.Style("fg: 111")
            @test s.fg == "111111"
            @test s.bg == Themes.NULL_STRING
            @test !s.bold
            @test !s.italic
            @test !s.underline
        end
        let s = Themes.Style("bg: f8c; italic; bold")
            @test s.fg == Themes.NULL_STRING
            @test s.bg == "ff88cc"
            @test s.bold
            @test s.italic
            @test !s.underline
        end
    end
    @testset "Format" begin
        local render = function(mime, style)
            local buffer = IOBuffer()
            Highlights.Format.render(buffer, mime, style)
            return takebuf_string(buffer)
        end
        @testset "CSS" begin
            let mime = MIME("text/css")
                @test render(mime, Themes.Style("fg: 111"))   == "color: #111111; "
                @test render(mime, Themes.Style("bg: 111"))   == "background-color: #111111; "
                @test render(mime, Themes.Style("bold"))      == "font-weight: bold; "
                @test render(mime, Themes.Style("italic"))    == "font-style: italic; "
                @test render(mime, Themes.Style("underline")) == "text-decoration: underline; "
            end
        end
        @testset "LaTeX" begin
            let mime = MIME("text/latex")
                @test render(mime, Themes.Style("fg: 111"))   == "[1]{\\textcolor[HTML]{111111}{#1}}"
                @test render(mime, Themes.Style("bg: 111"))   == "[1]{\\colorbox[HTML]{111111}{#1}}"
                @test render(mime, Themes.Style("bold"))      == "[1]{\\textbf{#1}}"
                @test render(mime, Themes.Style("italic"))    == "[1]{\\textit{#1}}"
                @test render(mime, Themes.Style("underline")) == "[1]{\\underline{#1}}"
            end
        end
    end
    @testset "Compiler" begin
        let buf = IOBuffer()
            Highlights.Compiler.debug(buf, "x", Highlights.Lexers.JuliaLexer)
            @test takebuf_string(buf) == "<NAME> := \"x\"\n"
            # Should print nothing to STDOUT.
            Highlights.Compiler.debug("", Highlights.Lexers.JuliaLexer)
        end
    end
    @testset "Miscellaneous" begin
        @test Highlights.definition(Highlights.AbstractTheme) == Dict()
        @test Highlights.definition(Highlights.AbstractLexer) == Dict()

        @test Highlights.lexer("julia") == Lexers.JuliaLexer
        @test Highlights.lexer("jl") == Lexers.JuliaLexer
        @test_throws ArgumentError Highlights.lexer("???")
    end
end
