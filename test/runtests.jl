import Highlights
using ReferenceTests
using Test

import tectonic_jll
import Typst_jll
import tree_sitter_fortran_jll
import tree_sitter_go_jll
import tree_sitter_javascript_jll
import tree_sitter_julia_jll
import tree_sitter_matlab_jll
import tree_sitter_python_jll
import tree_sitter_r_jll
import tree_sitter_rust_jll
import tree_sitter_toml_jll

const SAMPLES_DIR = joinpath(@__DIR__, "samples")
read_sample(name) = read(joinpath(SAMPLES_DIR, name), String)

@testset "Highlights" begin
    @testset "ANSI utilities" begin
        @test Highlights.hex_to_rgb("#FF0000") == (255, 0, 0)
        @test Highlights.hex_to_rgb("00FF00") == (0, 255, 0)
        @test Highlights.hex_to_rgb("#0000FF") == (0, 0, 255)

        @test Highlights.ansi_color_from_hex("#FF0000") == "\e[38;2;255;0;0m"
        @test Highlights.ansi_reset() == "\e[0m"
    end

    @testset "Theme loading" begin
        themes = Highlights.available_themes()
        @test !isempty(themes)
        @test "Dracula" in themes

        theme = Highlights.load_theme("Dracula")
        @test theme.name == "Dracula"
        @test haskey(theme.colors, 1)
        @test haskey(theme.colors, 16)
        @test startswith(theme.background, "#")

        # Caching
        theme2 = Highlights.load_theme("Dracula")
        @test theme === theme2

        @test_throws ErrorException Highlights.load_theme("NonExistentTheme")

        # Suggestions in error message
        err = try
            Highlights.load_theme("monokai")
        catch e
            e
        end
        @test contains(err.msg, "Similar themes:")
        @test contains(err.msg, "Monokai")
    end

    @testset "Theme from file" begin
        mktempdir() do dir
            path = joinpath(dir, "theme.json")
            open(path, "w") do io
                write(
                    io,
                    """{"name": "FileTheme", "background": "#111111", "foreground": "#eeeeee", "color_02": "#ff0000"}""",
                )
            end

            # Load from file
            theme = Highlights.load_theme(path)
            @test theme.name == "FileTheme"
            @test theme.background == "#111111"
            @test theme.colors[2] == "#ff0000"

            # Not cached (can edit file)
            theme2 = Highlights.load_theme(path)
            @test theme !== theme2

            # Derive from file
            custom = Highlights.Theme(path, colors = Dict(3 => "#00ff00"))
            @test custom.colors[2] == "#ff0000"
            @test custom.colors[3] == "#00ff00"
        end

        # Non-existent .json falls back to name lookup (and errors)
        @test_throws ErrorException Highlights.load_theme("nonexistent.json")
    end

    @testset "Theme derivation" begin
        # Derive from name
        custom = Highlights.Theme("Dracula", colors = Dict(2 => "#ff0000"))
        @test custom.name == "Dracula"
        @test custom.colors[2] == "#ff0000"
        @test custom.background == Highlights.load_theme("Dracula").background

        # Override name
        named = Highlights.Theme("Dracula", name = "MyTheme")
        @test named.name == "MyTheme"

        # Override background/foreground
        styled = Highlights.Theme("Dracula", background = "#111111", foreground = "#eeeeee")
        @test styled.background == "#111111"
        @test styled.foreground == "#eeeeee"

        # Chain from Theme object
        base = Highlights.Theme("Dracula", background = "#1a1a1a")
        chained = Highlights.Theme(base, colors = Dict(3 => "#00ff00"))
        @test chained.background == "#1a1a1a"
        @test chained.colors[3] == "#00ff00"
    end

    @testset "Theme fallbacks" begin
        # Missing colors get defaults, then contrast adjustment
        theme_data =
            Dict("name" => "Minimal", "background" => "#000000", "foreground" => "#FFFFFF")
        theme = Highlights.parse_theme(theme_data)
        # Colors 2-8 use dark fallback, 10-16 use bright fallback
        @test theme.colors[2] == "#000000"
        @test theme.colors[10] == "#FFFFFF"
        # Color 1 (comments) may be swapped with 9 for better contrast
        @test theme.colors[1] in ("#000000", "#FFFFFF")

        # Low contrast triggers blending
        theme_data2 = Dict(
            "name" => "LowContrast",
            "background" => "#808080",
            "foreground" => "#888888",
            "color_01" => "#808080",
            "color_09" => "#828282",
        )
        theme2 = Highlights.parse_theme(theme_data2)
        # Comment color should be blended (not original color_01 or color_09)
        @test theme2.colors[1] != "#808080"
        @test theme2.colors[1] != "#828282"
    end

    @testset "Theme suggestions" begin
        # Levenshtein distance
        @test Highlights.levenshtein("", "") == 0
        @test Highlights.levenshtein("abc", "") == 3
        @test Highlights.levenshtein("", "abc") == 3
        @test Highlights.levenshtein("abc", "abc") == 0
        @test Highlights.levenshtein("abc", "abd") == 1
        @test Highlights.levenshtein("kitten", "sitting") == 3

        # Unicode support
        @test Highlights.levenshtein("café", "cafe") == 1

        # Suggest themes
        themes = ["Dracula", "Nord", "Monokai Dark", "Monokai Pro"]
        suggestions = Highlights.suggest_themes("monokai", themes; limit = 2)
        @test length(suggestions) == 2
        @test "Monokai Dark" in suggestions || "Monokai Pro" in suggestions

        # Case-insensitive
        suggestions = Highlights.suggest_themes("DRACULA", themes; limit = 1)
        @test suggestions[1] == "Dracula"
    end

    @testset "Capture color mapping" begin
        colors = Highlights.default_capture_colors()

        # Exact match
        @test Highlights.get_capture_color("keyword", colors) == 2

        # Hierarchical fallback
        @test Highlights.get_capture_color("function.builtin", colors) == 13
        @test Highlights.get_capture_color("function.custom.deep", colors) == 5

        # Unknown defaults to 8
        @test Highlights.get_capture_color("unknown.capture", colors) == 8
    end

    @testset "Token deduplication" begin
        priorities = Highlights.default_capture_priorities()

        # Higher priority wins for same range
        tokens = [
            Highlights.HighlightToken("main", "variable", (5, 8), nothing),
            Highlights.HighlightToken("main", "function", (5, 8), nothing),
        ]
        result = Highlights.deduplicate_tokens(tokens, priorities)
        @test length(result) == 1
        @test result[1].capture == "function"

        # Non-overlapping preserved
        tokens = [
            Highlights.HighlightToken("int", "type", (1, 3), nothing),
            Highlights.HighlightToken("main", "function", (5, 8), nothing),
        ]
        result = Highlights.deduplicate_tokens(tokens, priorities)
        @test length(result) == 2

        # Empty input
        @test isempty(
            Highlights.deduplicate_tokens(Highlights.HighlightToken[], priorities),
        )
    end

    @testset "HTML escaping" begin
        @test Highlights.escape_html("<script>") == "&lt;script&gt;"
        @test Highlights.escape_html("a & b") == "a &amp; b"
        @test Highlights.escape_html("\"quoted\"") == "&quot;quoted&quot;"
    end

    @testset "LaTeX escaping" begin
        @test Highlights.escape_latex("a_b") == "a\\_b"
        @test Highlights.escape_latex("100%") == "100\\%"
        @test Highlights.escape_latex("{x}") == "\\{x\\}"
        @test Highlights.escape_latex("x~y") == "x\\textasciitilde{}y"
    end

    @testset "Typst escaping" begin
        # New format uses #"..." raw strings
        @test Highlights.escape_typst("\$x\$") == "#\"\$x\$\""
        @test Highlights.escape_typst("#func") == "#\"#func\""
        @test Highlights.escape_typst("a_b") == "#\"a_b\""
        @test Highlights.escape_typst("[x]") == "#\"[x]\""
        @test Highlights.escape_typst("*bold*") == "#\"*bold*\""
    end

    @testset "Highlighting output" begin
        @test_reference "references/julia.txt" Highlights.highlight(
            "text/plain",
            read_sample("fib.jl"),
            :julia,
            "Dracula",
        )
        @test_reference "references/python.txt" Highlights.highlight(
            "text/plain",
            read_sample("quicksort.py"),
            :python,
            "Dracula",
        )
        @test_reference "references/javascript.txt" Highlights.highlight(
            "text/plain",
            read_sample("emitter.js"),
            :javascript,
            "Dracula",
        )
        @test_reference "references/rust.txt" Highlights.highlight(
            "text/plain",
            read_sample("readfile.rs"),
            :rust,
            "Dracula",
        )
        @test_reference "references/go.txt" Highlights.highlight(
            "text/plain",
            read_sample("sieve.go"),
            :go,
            "Dracula",
        )
        @test_reference "references/fortran.txt" Highlights.highlight(
            "text/plain",
            read_sample("hello.f90"),
            :fortran,
            "Dracula",
        )
        @test_reference "references/matlab.txt" Highlights.highlight(
            "text/plain",
            read_sample("classdef.m"),
            :matlab,
            "Dracula",
        )
        @test_reference "references/r.txt" Highlights.highlight(
            "text/plain",
            read_sample("stats.r"),
            :r,
            "Dracula",
        )
        @test_reference "references/toml.txt" Highlights.highlight(
            "text/plain",
            read_sample("config.toml"),
            :toml,
            "Dracula",
        )
    end

    @testset "Output formats" begin
        code = read_sample("fib.jl")
        @test_reference "references/format_ansi.txt" Highlights.highlight(
            code,
            :julia,
            "Dracula",
        )
        @test_reference "references/format_html.txt" Highlights.highlight(
            "text/html",
            code,
            :julia,
            "Dracula",
        )
        @test_reference "references/format_latex.txt" Highlights.highlight(
            "text/latex",
            code,
            :julia,
            "Dracula",
        )
        @test_reference "references/format_typst.txt" Highlights.highlight(
            "text/typst",
            code,
            :julia,
            "Dracula",
        )

        # Fortran
        @test_reference "references/fortran_ansi.txt" Highlights.highlight(
            read_sample("hello.f90"),
            :fortran,
            "Dracula",
        )
        @test_reference "references/fortran_html.txt" Highlights.highlight(
            "text/html",
            read_sample("hello.f90"),
            :fortran,
            "Dracula",
        )
        @test_reference "references/fortran_latex.txt" Highlights.highlight(
            "text/latex",
            read_sample("hello.f90"),
            :fortran,
            "Dracula",
        )
        @test_reference "references/fortran_typst.txt" Highlights.highlight(
            "text/typst",
            read_sample("hello.f90"),
            :fortran,
            "Dracula",
        )

        # MATLAB
        @test_reference "references/matlab_ansi.txt" Highlights.highlight(
            read_sample("classdef.m"),
            :matlab,
            "Dracula",
        )
        @test_reference "references/matlab_html.txt" Highlights.highlight(
            "text/html",
            read_sample("classdef.m"),
            :matlab,
            "Dracula",
        )
        @test_reference "references/matlab_latex.txt" Highlights.highlight(
            "text/latex",
            read_sample("classdef.m"),
            :matlab,
            "Dracula",
        )
        @test_reference "references/matlab_typst.txt" Highlights.highlight(
            "text/typst",
            read_sample("classdef.m"),
            :matlab,
            "Dracula",
        )

        # R
        @test_reference "references/r_ansi.txt" Highlights.highlight(
            read_sample("stats.r"),
            :r,
            "Dracula",
        )
        @test_reference "references/r_html.txt" Highlights.highlight(
            "text/html",
            read_sample("stats.r"),
            :r,
            "Dracula",
        )
        @test_reference "references/r_latex.txt" Highlights.highlight(
            "text/latex",
            read_sample("stats.r"),
            :r,
            "Dracula",
        )
        @test_reference "references/r_typst.txt" Highlights.highlight(
            "text/typst",
            read_sample("stats.r"),
            :r,
            "Dracula",
        )

        # TOML
        @test_reference "references/toml_ansi.txt" Highlights.highlight(
            read_sample("config.toml"),
            :toml,
            "Dracula",
        )
        @test_reference "references/toml_html.txt" Highlights.highlight(
            "text/html",
            read_sample("config.toml"),
            :toml,
            "Dracula",
        )
        @test_reference "references/toml_latex.txt" Highlights.highlight(
            "text/latex",
            read_sample("config.toml"),
            :toml,
            "Dracula",
        )
        @test_reference "references/toml_typst.txt" Highlights.highlight(
            "text/typst",
            read_sample("config.toml"),
            :toml,
            "Dracula",
        )
    end

    @testset "Theme variation" begin
        code = "x = 1 + 2"
        @test_reference "references/theme_nord.txt" Highlights.highlight(
            code,
            :julia,
            "Nord",
        )
    end

    @testset "Stylesheet generation" begin
        @test_reference "references/stylesheet_css.txt" Highlights.stylesheet("Dracula")
        @test_reference "references/stylesheet_html.txt" Highlights.stylesheet(
            "text/html",
            "Dracula",
        )
        @test_reference "references/stylesheet_latex.txt" Highlights.stylesheet(
            "text/latex",
            "Dracula",
        )
    end

    @testset "External stylesheet formats" begin
        code = read_sample("fib.jl")
        @test_reference "references/format_html_external.txt" Highlights.highlight(
            "text/html",
            code,
            :julia,
            "Dracula";
            stylesheet = true,
        )
        @test_reference "references/format_latex_external.txt" Highlights.highlight(
            "text/latex",
            code,
            :julia,
            "Dracula";
            stylesheet = true,
        )
    end

    @testset "Stylesheet mode with REPL prefixes" begin
        import tree_sitter_python_jll
        code = ">>> s = \"\"\"\n... a\n... \"\"\"\n"

        # HTML: prefixes use class instead of inline style
        html = Highlights.highlight("text/html", code, :pycon, "Dracula"; stylesheet = true)
        @test contains(html, "<span class=\"hl-c12\">... </span>")
        @test !contains(html, "style=\"color:")

        # LaTeX: prefixes use command instead of textcolor
        latex =
            Highlights.highlight("text/latex", code, :pycon, "Dracula"; stylesheet = true)
        @test contains(latex, "\\HLCl{... }")
        @test !contains(latex, "\\textcolor")
    end

    @testset "Edge cases" begin
        # Empty input
        @test Highlights.highlight("", :julia, "Dracula") == ""

        # Unicode identifiers and strings
        unicode_code = """
        café = "日本語"
        λ = x -> x + 1
        """
        result = Highlights.highlight(unicode_code, :julia, "Dracula")
        @test contains(result, "café")
        @test contains(result, "日本語")
        @test contains(result, "λ")

        # Whitespace-only
        @test Highlights.highlight("   \n\t  ", :julia, "Dracula") == "   \n\t  "
    end

    @testset "Highlighting API" begin
        code = "x = 1"

        # Language specifiers: module, symbol, string
        r1 = Highlights.highlight(code, tree_sitter_julia_jll, "Dracula")
        r2 = Highlights.highlight(code, :julia, "Dracula")
        r3 = Highlights.highlight(code, "julia", "Dracula")
        @test r1 == r2 == r3

        # Case insensitivity
        @test Highlights.highlight(code, :Julia, "Dracula") == r2
        @test Highlights.highlight(code, "JULIA", "Dracula") == r2

        # MIME specifiers
        @test Highlights.highlight(MIME("text/ansi"), code, :julia, "Dracula") == r2
        @test Highlights.highlight("text/ansi", code, :julia, "Dracula") == r2

        # Invalid MIME
        @test_throws MethodError Highlights.highlight(
            MIME("text/invalid"),
            code,
            :julia,
            "Dracula",
        )

        # Invalid language error handling
        @static if VERSION >= v"1.7"
            # Should suggest similar packages
            err = try
                Highlights.highlight(code, :jula, "Dracula")
            catch e
                e
            end
            err_str = sprint(showerror, err)
            @test contains(err_str, "Language 'jula' not found")
            @test contains(err_str, "julia (tree_sitter_julia_jll)")
        else
            # On 1.6, registry scanning unavailable
            @test_throws ErrorException Highlights.highlight(code, :jula, "Dracula")
        end
    end

    @testset "Language suggestions" begin
        # Extract language name helper
        @test Highlights.extract_language_name("tree_sitter_julia_jll") == "julia"
        @test Highlights.extract_language_name("tree_sitter_c_sharp_jll") == "c_sharp"

        # Available languages from registry (requires Julia 1.7+)
        @static if VERSION >= v"1.7"
            langs = Highlights.available_languages()
            @test length(langs) > 0
            @test issorted(langs)
            @test all(l -> !startswith(l, "tree_sitter_"), langs)

            jlls = Highlights.available_language_jlls()
            @test length(jlls) > 0
            @test all(j -> startswith(j, "tree_sitter_") && endswith(j, "_jll"), jlls)
        end

        # Suggestion ordering by levenshtein distance
        test_jlls = [
            "tree_sitter_julia_jll",
            "tree_sitter_lua_jll",
            "tree_sitter_java_jll",
            "tree_sitter_rust_jll",
        ]
        suggestions = Highlights.suggest_language_jlls("jula", test_jlls; limit = 3)
        @test length(suggestions) == 3
        @test suggestions[1] == ("julia", "tree_sitter_julia_jll")

        # Smarter limiting: clear winner reduces suggestions
        suggestions = Highlights.suggest_language_jlls("julia", test_jlls; limit = 5)
        @test length(suggestions) <= 3  # "julia" is exact match, others are far

        # Language aliases
        @test haskey(Highlights.LANGUAGE_ALIASES, "js")
        @test Highlights.LANGUAGE_ALIASES["js"] == "javascript"
        @test Highlights.LANGUAGE_ALIASES["py"] == "python"
    end

    @testset "IO output" begin
        code = "x = 1"

        # IO variant returns same as String variant
        buf = IOBuffer()
        Highlights.highlight(buf, MIME("text/ansi"), code, :julia, "Dracula")
        @test String(take!(buf)) == Highlights.highlight(code, :julia, "Dracula")

        buf = IOBuffer()
        Highlights.highlight(buf, "text/html", code, :julia, "Dracula")
        @test String(take!(buf)) ==
              Highlights.highlight("text/html", code, :julia, "Dracula")
    end

    @testset "Transform keyword" begin
        code = "x = 1"

        # Default transform is no-op
        result1 = Highlights.highlight("text/html", code, :julia, "Dracula")
        result2 = Highlights.highlight(
            "text/html",
            code,
            :julia,
            "Dracula";
            transform = Highlights.default_transform,
        )
        @test result1 == result2

        # Custom transform wraps tokens (HTML)
        function wrap_html(
            io::IO,
            ::MIME"text/html",
            token,
            entering::Bool,
            source,
            language,
        )
            if entering
                print(io, "[$(token.capture)]")
            else
                print(io, "[/$(token.capture)]")
            end
        end
        wrap_html(::IO, ::MIME, token, entering, source, language) = nothing

        result = Highlights.highlight(
            "text/html",
            code,
            :julia,
            "Dracula";
            transform = wrap_html,
        )
        @test contains(result, "[number]")
        @test contains(result, "[/number]")

        # Custom transform wraps tokens (ANSI)
        function wrap_ansi(
            io::IO,
            ::MIME"text/ansi",
            token,
            entering::Bool,
            source,
            language,
        )
            if entering
                print(io, "<<")
            else
                print(io, ">>")
            end
        end
        wrap_ansi(::IO, ::MIME, token, entering, source, language) = nothing

        result = Highlights.highlight(code, :julia, "Dracula"; transform = wrap_ansi)
        @test contains(result, "<<")
        @test contains(result, ">>")

        # Transform can selectively wrap only certain captures
        function link_funcs(
            io::IO,
            ::MIME"text/html",
            token,
            entering::Bool,
            source,
            language,
        )
            if token.capture == "function.call"
                if entering
                    print(io, "<a href=\"#\">")
                else
                    print(io, "</a>")
                end
            end
        end
        link_funcs(::IO, ::MIME, token, entering, source, language) = nothing

        result = Highlights.highlight(
            "text/html",
            "println(1)",
            :julia,
            "Dracula";
            transform = link_funcs,
        )
        @test contains(result, "<a href=\"#\">")
        @test contains(result, "</a>")
    end

    @testset "Transform with AST node" begin
        import TreeSitter

        code = "Base.println(1)"

        # Transform can access AST node for qualified name context
        function qualified_link(
            io::IO,
            ::MIME"text/html",
            token,
            entering::Bool,
            source,
            language,
        )
            if token.capture == "function.call" && entering
                if token.node !== nothing
                    p = TreeSitter.parent(token.node)
                    if !TreeSitter.is_null(p) &&
                       TreeSitter.node_type(p) == "field_expression"
                        print(io, "[", TreeSitter.slice(source, p), "]")
                        return
                    end
                end
                print(io, "[", token.text, "]")
            end
        end
        qualified_link(::IO, ::MIME, t, e, s, l) = nothing

        result = Highlights.highlight(
            "text/html",
            code,
            :julia,
            "Dracula";
            transform = qualified_link,
        )
        @test contains(result, "[Base.println]")

        # Verify token.node is available
        function check_node(
            io::IO,
            ::MIME"text/html",
            token,
            entering::Bool,
            source,
            language,
        )
            if entering && token.node !== nothing
                print(io, "<node>")
            end
        end
        check_node(::IO, ::MIME, t, e, s, l) = nothing

        result = Highlights.highlight(
            "text/html",
            "x = 1",
            :julia,
            "Dracula";
            transform = check_node,
        )
        @test contains(result, "<node>")
    end

    @testset "jlcon preprocessor" begin
        # Basic julia> prompt
        segments = Highlights.jlcon_preprocess("julia> x = 1\n2\n")
        @test length(segments) == 3  # prompt, code, output
        @test segments[1] isa Highlights.StyledSegment
        @test segments[1].text == "julia> "
        @test segments[1].color == 11  # bright green
        @test segments[2] isa Highlights.CodeSegment
        @test segments[2].language == :julia
        @test segments[3] isa Highlights.StyledSegment
        @test segments[3].color == 0  # foreground

        # Shell mode
        segments = Highlights.jlcon_preprocess("shell> ls\nfile.txt\n")
        @test segments[1].text == "shell> "
        @test segments[1].color == 10  # bright red
        @test segments[2] isa Highlights.CodeSegment
        @test segments[2].language == :bash

        # Help mode
        segments = Highlights.jlcon_preprocess("help?> sin\nsin(x)\n")
        @test segments[1].text == "help?> "
        @test segments[1].color == 12  # bright yellow
        @test segments[2].language == :julia

        # Pkg mode (no highlighting) - bare pkg>
        segments = Highlights.jlcon_preprocess("pkg> status\nStatus\n")
        @test segments[1].text == "pkg> "
        @test segments[1].color == 13  # bright blue
        @test segments[2] isa Highlights.StyledSegment  # pkg mode = no highlighting

        # Pkg mode with environment prefix
        segments = Highlights.jlcon_preprocess("(@v1.10) pkg> add Foo\nResolving\n")
        @test segments[1].text == "(@v1.10) pkg> "
        @test segments[1].color == 13

        # Continuation lines (7 spaces)
        segments = Highlights.jlcon_preprocess("julia> function f()\n       end\nf\n")
        @test segments[2] isa Highlights.CodeSegment
        @test contains(segments[2].text, "function f()")
        @test contains(segments[2].text, "end")

        # Blank line in middle of multi-line code
        segments = Highlights.jlcon_preprocess("julia> function f()\n\n       end\nf\n")
        @test segments[2] isa Highlights.CodeSegment
        @test contains(segments[2].text, "function f()")
        @test contains(segments[2].text, "\n\n")  # blank line preserved
        @test contains(segments[2].text, "end")
    end

    @testset "jlcon highlighting" begin
        import tree_sitter_bash_jll
        @test_reference "references/jlcon.txt" Highlights.highlight(
            read_sample("jlcon"),
            :jlcon,
            "Dracula",
        )
    end

    @testset "jlcon with LaTeX" begin
        import tree_sitter_bash_jll
        result = Highlights.highlight("text/latex", "julia> 1+1\n2\n", :jlcon, "Dracula")
        @test contains(result, "\\begin{tcblisting}")
        @test contains(result, "\\end{tcblisting}")
    end

    @testset "REPL multiline tokens with prefixes" begin
        import tree_sitter_python_jll
        # Pycon has "... " continuation prefix - tests emit_prefix mid-token
        code = ">>> s = \"\"\"\n... a\n... b\n... \"\"\"\n"

        # HTML: continuation prefixes should be styled spans inside the string
        html = Highlights.highlight("text/html", code, :pycon, "Dracula")
        # Prefix "... " wrapped in styled span (yellow #F1FA8C for pycon)
        @test contains(html, "<span style=\"color: #F1FA8C\">... </span>")
        # Should appear 3 times (one per continuation line)
        @test count("<span style=\"color: #F1FA8C\">... </span>", html) == 3

        # LaTeX: continuation prefixes should use textcolor
        latex = Highlights.highlight("text/latex", code, :pycon, "Dracula")
        # Prefix wrapped in textcolor command
        @test contains(latex, "\\textcolor[RGB]{241,250,140}{... }")
        @test count("\\textcolor[RGB]{241,250,140}{... }", latex) == 3

        # Typst: continuation prefixes should use #text(fill: ...)[#raw(...)]
        typst = Highlights.highlight("text/typst", code, :pycon, "Dracula")
        @test contains(typst, "#text(fill: rgb(241, 250, 140))[#raw(\"... \")]")
        @test count("#text(fill: rgb(241, 250, 140))[#raw(\"... \")]", typst) == 3
    end

    @testset "pycon preprocessor" begin
        # Basic >>> prompt
        segments = Highlights.pycon_preprocess(">>> x = 1\n1\n")
        @test length(segments) == 3
        @test segments[1].text == ">>> "
        @test segments[1].color == 12  # bright yellow
        @test segments[2] isa Highlights.CodeSegment
        @test segments[2].language == :python

        # Continuation with ...
        segments = Highlights.pycon_preprocess(">>> def f():\n...     pass\n")
        @test segments[2] isa Highlights.CodeSegment
        @test contains(segments[2].text, "def f():")
        @test contains(segments[2].text, "pass")
    end

    @testset "pycon highlighting" begin
        import tree_sitter_python_jll
        @test_reference "references/pycon.txt" Highlights.highlight(
            read_sample("pycon"),
            :pycon,
            "Dracula",
        )
    end

    @testset "rcon preprocessor" begin
        # Basic > prompt
        segments = Highlights.rcon_preprocess("> x <- 1\n[1] 1\n")
        @test length(segments) == 3
        @test segments[1].text == "> "
        @test segments[1].color == 13  # bright blue
        @test segments[2] isa Highlights.CodeSegment
        @test segments[2].language == :r

        # Continuation with +
        segments = Highlights.rcon_preprocess("> function(x) {\n+ x + 1\n+ }\n")
        @test segments[2] isa Highlights.CodeSegment
        @test contains(segments[2].text, "function(x)")
        @test contains(segments[2].text, "x + 1")
    end

    @testset "rcon highlighting" begin
        import tree_sitter_r_jll
        @test_reference "references/rcon.txt" Highlights.highlight(
            read_sample("rcon"),
            :rcon,
            "Dracula",
        )
    end

    @testset "LaTeX compilation" begin
        code = "x = 1 + 2"
        packages = "\\usepackage{xcolor}\n\\usepackage{listings}\n\\usepackage[listings,breakable]{tcolorbox}\n"

        # Test inline mode (packages provided in preamble)
        mktempdir() do dir
            tex = joinpath(dir, "test.tex")
            content =
                "\\documentclass{article}\n" *
                packages *
                "\\begin{document}\n" *
                Highlights.highlight("text/latex", code, :julia, "Dracula") *
                "\n\\end{document}"
            write(tex, content)
            @test success(run(`$(tectonic_jll.tectonic()) -X compile $tex`))
        end

        # Test stylesheet mode
        mktempdir() do dir
            tex = joinpath(dir, "test.tex")
            content =
                "\\documentclass{article}\n" *
                Highlights.stylesheet("text/latex", "Dracula") *
                "\n\\begin{document}\n" *
                Highlights.highlight(
                    "text/latex",
                    code,
                    :julia,
                    "Dracula";
                    stylesheet = true,
                ) *
                "\n\\end{document}"
            write(tex, content)
            @test success(run(`$(tectonic_jll.tectonic()) -X compile $tex`))
        end
    end

    @testset "Typst compilation" begin
        code = "x = 1 + 2"

        mktempdir() do dir
            typ = joinpath(dir, "test.typ")
            pdf = joinpath(dir, "test.pdf")
            content = Highlights.highlight("text/typst", code, :julia, "Dracula")
            write(typ, content)
            @test success(run(`$(Typst_jll.typst()) compile $typ $pdf`))
        end
    end
end
