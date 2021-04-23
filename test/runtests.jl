using Highlights

using Test
using InteractiveUtils

#
# Utilities.
#

function tokentest(lexer, source, expects...)
    tokens = Highlights.Compiler.lex(source, lexer).tokens
    @test length(tokens) == length(expects)
    @test join([s for (n, s) in expects]) == source
    for (token, (name, str)) in zip(tokens, expects)
        @test token.value == name
        @test SubString(source, token.first, token.last) == str
    end
end

function print_all(lexer, file)
    source = read(joinpath(@__DIR__, "samples", file), String)
    buffer = IOBuffer()
    for m in ["html", "latex"]
        mime = MIME("text/$m")
        for theme in subtypes(Themes.AbstractTheme)
            stylesheet(buffer, mime, theme)
            highlight(buffer, mime, source, lexer, theme)
        end
    end
    return buffer
end

#
# Setup.
#

using Highlights.Tokens, Highlights.Themes, Highlights.Lexers

# Error reporting for broken lexers.
abstract type BrokenLexer <: Highlights.AbstractLexer end
@lexer BrokenLexer Dict(
    :tokens => Dict(:root => [(r"\w+", TEXT, (:b, :a))], :a => [], :b => []),
)

# Lexer inheritance.
abstract type ParentLexer <: Highlights.AbstractLexer end
abstract type ChildLexer <: ParentLexer end
@lexer ParentLexer Dict(
    :tokens => Dict(:root => [(r"#.*$"m, COMMENT)])
)
@lexer ChildLexer Dict(
    :tokens => Dict(:root => [:__inherit__, (r"\d+", NUMBER), (r".", TEXT)])
)

abstract type NumberLexer <: Highlights.AbstractLexer end
@lexer NumberLexer Dict(
    :tokens => Dict(
        :root => [
            (r"0b[0-1]+", NUMBER_BIN),
            (r"0o[0-7]+", NUMBER_OCT),
            (r"0x[0-9a-f]+", NUMBER_HEX),
        ],
        :integers => [
            (r"\d+", NUMBER_INTEGER),
        ],
    ),
)

abstract type SelfLexer <: Highlights.AbstractLexer end
@lexer SelfLexer Dict(
    :tokens => Dict(
        :root => [
            (r"(#)( )(.+)(;)$"m, (COMMENT, WHITESPACE, :root, PUNCTUATION)),
            (r"(!)( )(.+)(;)$"m, (COMMENT, WHITESPACE, :string, PUNCTUATION)),
            (r"\d+", NUMBER),
            (r"\w+", NAME),
            (r" ", WHITESPACE),
        ],
        :string => [
            (r"'[^']*'", STRING),
            (r"0[box][\da-f]+", NumberLexer),
            (r"\d+", NumberLexer => :integers),
            (r"\s", WHITESPACE),
        ],
    ),
)

# Custom output format. A DOM-like node "buffer".

struct Node
    name::Symbol
    text::String
    class::String
end

struct NodeBuffer <: IO
    nodes::Vector{Node}
end

function Format.render(io::IO, ::MIME"ast/dom", tokens::Format.TokenIterator)
    for (str, id, style) in tokens
        push!(io.nodes, Node(:span, str, "hljl-$id"))
    end
end

#
# Testsets.
#

@testset "Highlights" begin
    @testset "Lexers" begin
        @testset for file in readdir(joinpath(@__DIR__, "lexers"))
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
            tokentest(
                SelfLexer,
                "! '...';",
                COMMENT => "!",
                WHITESPACE => " ",
                STRING => "'...'",
                PUNCTUATION => ";",
            )
            tokentest(
                SelfLexer,
                "! 0b1010;",
                COMMENT => "!",
                WHITESPACE => " ",
                NUMBER_BIN => "0b1010",
                PUNCTUATION => ";",
            )
            tokentest(
                SelfLexer,
                "! 0b1010 0xacd1;",
                COMMENT => "!",
                WHITESPACE => " ",
                NUMBER_BIN => "0b1010",
                WHITESPACE => " ",
                NUMBER_HEX => "0xacd1",
                PUNCTUATION => ";",
            )
            tokentest(
                SelfLexer,
                "! 1234 0b01;",
                COMMENT => "!",
                WHITESPACE => " ",
                NUMBER_INTEGER => "1234",
                WHITESPACE => " ",
                NUMBER_BIN => "0b01",
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
        @testset "Utilities" begin
            let w = Lexers.words(["if", "else"]; prefix = "\\b", suffix = "\\b")
                @test occursin(w, "if")
                @test !occursin(w, "for")
                @test !occursin(w, "ifelse")
            end
            let c = Highlights.Compiler.Context("@lexer CustomLexer dict(")
                @test Lexers.julia_is_macro_identifier(c) == 1:6
                @test Lexers.julia_is_iterp_identifier(c) == 0:0
            end
            let c = Highlights.Compiler.Context("raw\"\"\"...\"\"\"")
                @test Lexers.julia_is_triple_string_macro(c) == 1:6
            end
        end
        @testset "Errors" begin
            tokentest(BrokenLexer, " ", ERROR => " ")
        end
    end
    @testset "Themes" begin
        let s = Themes.Style("fg: 111")
            @test s.fg.r == 0x11
            @test s.fg.g == 0x11
            @test s.fg.b == 0x11
            @test s.fg.active == true

            @test s.bg.r == 0x00
            @test s.bg.g == 0x00
            @test s.bg.b == 0x00
            @test s.bg.active == false

            @test !s.bold
            @test !s.italic
            @test !s.underline
        end
        let s = Themes.Style("bg: f8c; italic; bold")
            @test s.fg.r == 0x00
            @test s.fg.g == 0x00
            @test s.fg.b == 0x00
            @test s.fg.active == false

            @test s.bg.r == 0xff
            @test s.bg.g == 0x88
            @test s.bg.b == 0xcc
            @test s.bg.active == true
            @test s.bold
            @test s.italic
            @test !s.underline
        end
        let t = Themes.maketheme(Themes.DefaultTheme),
            m = Themes.metadata(Themes.DefaultTheme)
            @test t.base == m[:style]
            @test t.styles[1] == m[:tokens][TEXT]
        end
    end
    @testset "Format" begin
        render = function(mime, style)
            buffer = IOBuffer()
            Highlights.Format.render(buffer, mime, style)
            return Highlights.takebuf_str(buffer)
        end
        @testset "CSS" begin
            let mime = MIME("text/css")
                @test render(mime, Themes.Style("fg: 111"))   == "color: rgb(17,17,17); "
                @test render(mime, Themes.Style("bg: 111"))   == "background-color: rgb(17,17,17); "
                @test render(mime, Themes.Style("bold"))      == "font-weight: bold; "
                @test render(mime, Themes.Style("italic"))    == "font-style: italic; "
                @test render(mime, Themes.Style("underline")) == "text-decoration: underline; "
            end
        end
        @testset "LaTeX" begin
            escape = function(mime,str;charescape=false)
                buffer = IOBuffer()
                Highlights.Format.escape(buffer,mime,str,charescape=charescape)
                return Highlights.takebuf_str(buffer)
            end
            render_nonwhitespace = function(mime,str)
                buffer = IOBuffer()
                Highlights.Format.render_nonwhitespace(buffer,mime,str,0,nothing)
                return Highlights.takebuf_str(buffer)
            end
            escapeinside(str) = "(*@{"*str*"}@*)"
            let mime = MIME("text/latex")
                @test render(mime, Themes.Style("fg: 111"))   == "[1]{\\textcolor[RGB]{17,17,17}{#1}}"
                @test render(mime, Themes.Style("bg: 111"))   == "[1]{\\colorbox[RGB]{17,17,17}{#1}}"
                @test render(mime, Themes.Style("bold"))      == "[1]{\\textbf{#1}}"
                @test render(mime, Themes.Style("italic"))    == "[1]{\\textit{#1}}"
                @test render(mime, Themes.Style("underline")) == "[1]{\\underline{#1}}"
                mime = MIME("text/latex")
                ebrace_L = escape(mime,"{")
                ebrace_R = escape(mime,"}")
                # This is placed in a verbatim env. so there must be an additional charescape
                @test escape(mime,"{}",charescape=true) == escapeinside(ebrace_L)*escapeinside(ebrace_R)
                # This is already escaped so now charescape
                @test escape(mime,"{}",charescape=false) == ebrace_L*ebrace_R
                # This is placed in a verbatim so whitespace is already handled by the verbatim env.
                # Only special characters need to be escaped
                @test escape(mime,"   some text\n next line{}",charescape=true) ==
                    "   some text\n next line"*escapeinside(ebrace_L)*escapeinside(ebrace_R)
                # This is escaped so LaTeX automatically removes whitespace characters.
                # Also no additional escapeinside for special characters needed.
                s = escape(mime," ",charescape=false)
                @test escape(mime,"   some text\n next line{}",charescape=false) ==
                    "$(s)$(s)$(s)some$(s)text\n$(s)next$(s)line"*ebrace_L*ebrace_R
                r(x) = "(*@\\HLJL0{$x}@*)"
                @test render_nonwhitespace(MIME("text/latex"),"\tfoo  \nbar\t") == "\t"*r("foo")*"  \n"*r("bar")*"\t"
                @test render_nonwhitespace(MIME("text/latex"),"foo") == r("foo")
                @test render_nonwhitespace(MIME("text/latex"),"\t") == "\t"
                @test render_nonwhitespace(MIME("text/latex"),"α") == r("α")
                @test render_nonwhitespace(MIME("text/latex")," α\tβfoo ") == " "*r("α")*"\t"*r("βfoo")*" "
                @test render_nonwhitespace(MIME("text/latex")," α ") == " "*r("α")*" "
            end
        end
        @testset "Custom Nodes" begin
            let buf = NodeBuffer([]),
                eq = (a, b) -> a.name == b.name && a.text == b.text && a.class == b.class
                highlight(buf, MIME("ast/dom"), "x = 1", Lexers.JuliaLexer)
                @test eq(buf.nodes[1], Node(:span, "x", "hljl-n"))
                @test eq(buf.nodes[2], Node(:span, " ", "hljl-t"))
                @test eq(buf.nodes[3], Node(:span, "=", "hljl-oB"))
                @test eq(buf.nodes[4], Node(:span, " ", "hljl-t"))
                @test eq(buf.nodes[5], Node(:span, "1", "hljl-ni"))
            end
        end
    end
    @testset "Compiler" begin
        let buf = IOBuffer()
            Highlights.Compiler.debug(buf, "x", Highlights.Lexers.JuliaLexer)
            @test Highlights.takebuf_str(buf) == "<NAME> := \"x\"\n"
            # Should print nothing to STDOUT.
            Highlights.Compiler.debug("", Highlights.Lexers.JuliaLexer)
        end
    end
    @testset "Tokens" begin
        @test Highlights.Tokens.TokenValue(:TEXT).value == 1
        @test Highlights.Tokens.parent(:TEXT) == :TEXT
        @test Highlights.Tokens.parent(:COMMENT) == :TEXT
        @test Highlights.Tokens.parent(:COMMENT_SINGLE) == :COMMENT
    end
    @testset "Miscellaneous" begin
        @test Highlights.lexer("julia") == Lexers.JuliaLexer
        @test Highlights.lexer("jl") == Lexers.JuliaLexer
        @test_throws ArgumentError Highlights.lexer("???")
    end
end

# Hack to make the test in External actually usable...
using Pkg
Pkg.activate(joinpath(@__DIR__, "External"))
Pkg.develop("Highlights")
using External
