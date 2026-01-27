# Display methods for Highlight and Theme types.

"""
    Highlight

Displayable syntax-highlighted code. Unlike `highlight()` which returns a String,
`Highlight` objects integrate with Julia's display system via `show` methods.

# Example

```julia
code = Highlight("println(1)", :julia, "Dracula")
display(code)                        # ANSI in terminal
display(MIME"text/html"(), code)     # HTML output
```

# Constructors

```julia
Highlight(source, language, theme; kwargs...)
```

Arguments and keyword arguments match [`highlight`](@ref).
"""
struct Highlight
    source::String
    language::Module
    language_sym::Symbol
    theme::Theme
    transform::Function
    preprocess::Union{Nothing,Function}
    stylesheet::Bool
    classprefix::String
end

function Highlight(
    source::AbstractString,
    language,
    theme;
    transform = default_transform,
    preprocess = nothing,
    stylesheet::Bool = false,
    classprefix::AbstractString = "hl",
)
    lang_module = resolve_language(language)
    lang_sym = normalize_language(language)
    theme_obj = theme isa Theme ? theme : load_theme(theme)
    Highlight(
        String(source),
        lang_module,
        lang_sym,
        theme_obj,
        transform,
        preprocess,
        stylesheet,
        String(classprefix),
    )
end

# Helper to call highlight with stored fields
function _highlight(io::IO, mime::MIME, h::Highlight)
    highlight(
        io,
        mime,
        h.source,
        h.language,
        h.theme;
        transform = h.transform,
        preprocess = h.preprocess,
        stylesheet = h.stylesheet,
        classprefix = h.classprefix,
    )
end

Base.show(io::IO, ::MIME"text/html", h::Highlight) = _highlight(io, MIME("text/html"), h)
Base.show(io::IO, ::MIME"text/plain", h::Highlight) = _highlight(io, MIME("text/ansi"), h)
Base.show(io::IO, ::MIME"text/latex", h::Highlight) = _highlight(io, MIME("text/latex"), h)
Base.show(io::IO, ::MIME"text/typst", h::Highlight) = _highlight(io, MIME("text/typst"), h)
Base.show(io::IO, ::MIME"text/ansi", h::Highlight) = _highlight(io, MIME("text/ansi"), h)

# Theme show methods

function Base.show(io::IO, ::MIME"text/html", t::Theme)
    println(io, "<div style=\"font-family: monospace;\">")
    println(io, "<h3>", t.name, "</h3>")
    println(io, "<div style=\"display: flex; gap: 4px; margin-bottom: 8px;\">")
    println(
        io,
        "<div style=\"background: $(t.background); color: $(t.foreground); padding: 4px 8px; border: 1px solid #ccc;\">bg</div>",
    )
    println(
        io,
        "<div style=\"background: $(t.foreground); color: $(t.background); padding: 4px 8px; border: 1px solid #ccc;\">fg</div>",
    )
    println(io, "</div>")
    println(io, "<div style=\"display: flex; flex-wrap: wrap; gap: 4px;\">")
    for i = 1:16
        color = get(t.colors, i, "#000000")
        # Use white or black text for contrast
        r, g, b = hex_to_rgb(color)
        text_color = (r * 0.299 + g * 0.587 + b * 0.114) > 128 ? "#000" : "#fff"
        println(
            io,
            "<div style=\"background: $color; color: $text_color; width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; font-size: 10px;\">$i</div>",
        )
    end
    println(io, "</div>")
    println(io, "</div>")
end

function Base.show(io::IO, ::MIME"text/plain", t::Theme)
    print(io, "Theme(\"", t.name, "\")")
    if get(io, :compact, false)
        return
    end
    println(io)
    # ANSI preview: show color swatches
    for i = 1:8
        color = get(t.colors, i, "#000000")
        print(io, ansi_color_from_hex(color), "\u2588\u2588")
    end
    print(io, ansi_reset())
    println(io)
    for i = 9:16
        color = get(t.colors, i, "#ffffff")
        print(io, ansi_color_from_hex(color), "\u2588\u2588")
    end
    print(io, ansi_reset())
end
