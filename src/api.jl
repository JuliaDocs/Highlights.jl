# Main API functions

"""
    default_transform(io::IO, mime::MIME, token::HighlightToken, entering::Bool, source::AbstractString, language::Symbol)

No-op transform function. Users can provide a custom function to wrap tokens.

The transform is called twice per token:
- `entering=true` before the token is rendered (write opening wrapper)
- `entering=false` after the token is rendered (write closing wrapper)

# Arguments
- `io`: Output stream to write wrapper content
- `mime`: Output format MIME type
- `token`: The token with `.text`, `.capture`, `.byte_range`, `.node`
- `entering`: true before rendering, false after
- `source`: Full source code (for slicing AST nodes)
- `language`: Language being highlighted (e.g., `:julia`, `:bash`)

# Example: Language-aware linking

```julia
function link_docs(io::IO, ::MIME"text/html", token, entering::Bool, source, language)
    # Only link in Julia code
    language == :julia || return
    if token.capture == "function.call" && entering
        print(io, "<a href=\"/docs/\$(token.text)\">")
    elseif token.capture == "function.call" && !entering
        print(io, "</a>")
    end
end
link_docs(::IO, ::MIME, t, e, s, l) = nothing

highlight("text/html", code, :julia, "Dracula"; transform=link_docs)
```
"""
default_transform(::IO, ::MIME, ::HighlightToken, ::Bool, ::AbstractString, ::Symbol) =
    nothing

"""
    highlight(source::AbstractString, language, theme; transform=default_transform) -> String
    highlight(mime, source::AbstractString, language, theme; transform=default_transform) -> String
    highlight(io::IO, mime, source::AbstractString, language, theme; transform=default_transform)

Highlight source code using tree-sitter and a color theme.

# Arguments
- `source`: Source code to highlight
- `language`: Language specifier - JLL module, Symbol, or String (e.g., `:julia`, `"python"`)
- `theme`: Theme name (String) or `Theme` object (see `available_themes()`, custom themes below)
- `mime`: Output format as MIME type or string (default: `MIME("text/ansi")`)
  - `MIME("text/ansi")` or `"text/ansi"` - Terminal with 24-bit true color
  - `MIME("text/html")` or `"text/html"` - HTML with inline styles
  - `MIME("text/latex")` or `"text/latex"` - LaTeX with color commands
  - `MIME("text/plain")` or `"text/plain"` - Debug format with capture names
- `transform`: Function to wrap tokens (see `default_transform`)

# Language Resolution
Languages are case-insensitive and support common aliases:
- `js` → `javascript`
- `ts` → `typescript`
- `py` → `python`
- `rb` → `ruby`
- `yml` → `yaml`
- `rs` → `rust`
- `cs` → `c_sharp`
- `c++`, `cxx` → `cpp`
- `sh`, `shell`, `zsh` → `bash`
- `jl` → `julia`

If a language is not found, similar languages are suggested based on edit distance.
Use `available_languages()` to list all installable language grammars.

# Example
```julia
using Highlights

code = \"\"\"
function hello(name)
    println("Hello, \$name!")
end
\"\"\"

# Default ANSI output for terminal
println(highlight(code, :julia, "Dracula"))

# HTML output
html = highlight(MIME("text/html"), code, :julia, "Nord")

# Using string MIME
html = highlight("text/html", code, "julia", "Nord")

# Custom theme derived from Dracula
custom = Theme("Dracula", colors = Dict(2 => "#ff0000"))
println(highlight(code, :julia, custom))
```
"""
function highlight(
    source::AbstractString,
    language,
    theme;
    transform = default_transform,
    preprocess = nothing,
    stylesheet::Bool = false,
    classprefix::AbstractString = "hl",
)
    highlight(
        MIME("text/ansi"),
        source,
        language,
        theme;
        transform,
        preprocess,
        stylesheet,
        classprefix,
    )
end

function highlight(
    mime,
    source::AbstractString,
    language,
    theme;
    transform = default_transform,
    preprocess = nothing,
    stylesheet::Bool = false,
    classprefix::AbstractString = "hl",
)
    io = IOBuffer()
    highlight(
        io,
        mime,
        source,
        language,
        theme;
        transform,
        preprocess,
        stylesheet,
        classprefix,
    )
    return String(take!(io))
end

function highlight(
    io::IO,
    mime::AbstractString,
    source::AbstractString,
    language,
    theme;
    transform = default_transform,
    preprocess = nothing,
    stylesheet::Bool = false,
    classprefix::AbstractString = "hl",
)
    highlight(
        io,
        MIME(mime),
        source,
        language,
        theme;
        transform,
        preprocess,
        stylesheet,
        classprefix,
    )
end

function highlight(
    io::IO,
    mime::MIME,
    source::AbstractString,
    language,
    theme_name::String;
    kw...,
)
    highlight(io, mime, source, language, load_theme(theme_name); kw...)
end

function highlight(
    io::IO,
    mime::MIME,
    source::AbstractString,
    language,
    theme::Theme;
    transform = default_transform,
    preprocess = nothing,
    stylesheet::Bool = false,
    classprefix::AbstractString = "hl",
)
    lang_sym = normalize_language(language)

    # Auto-use preprocessor for pseudo-languages like :jlcon
    if preprocess === nothing
        preprocess = preprocessor(MIME("text/$lang_sym"))
    end

    if preprocess === nothing
        # Normal path - highlight entire source
        lang_module = resolve_language(language)
        parser = TreeSitter.Parser(lang_module)
        query = TreeSitter.Query(lang_module, ["highlights"])
        tokens = highlight_tokens(parser, query, source)
        format(
            io,
            mime,
            tokens,
            source,
            theme,
            lang_sym;
            transform,
            stylesheet,
            classprefix,
        )
    else
        # Preprocessor path - single wrapper around all segments
        segments = preprocess(source)
        format_begin(io, mime, theme; stylesheet, classprefix)
        for segment in segments
            if segment isa CodeSegment
                lang_module = resolve_language(segment.language)
                parser = TreeSitter.Parser(lang_module)
                query = TreeSitter.Query(lang_module, ["highlights"])
                tokens = highlight_tokens(parser, query, segment.text)
                format(
                    io,
                    mime,
                    tokens,
                    segment.text,
                    theme,
                    segment.language;
                    transform,
                    wrap = false,
                    stylesheet,
                    classprefix,
                    line_prefixes = segment.line_prefixes,
                )
            else
                format_styled(
                    io,
                    mime,
                    segment.text,
                    segment.color,
                    theme;
                    stylesheet,
                    classprefix,
                )
            end
        end
        format_end(io, mime, theme)
    end
    return nothing
end
