"""
    escape_html(io::IO, s::AbstractString)
    escape_html(s::AbstractString) -> String

Escape HTML special characters.
"""
function escape_html(io::IO, s::AbstractString)
    for char in s
        if char == '&'
            print(io, "&amp;")
        elseif char == '<'
            print(io, "&lt;")
        elseif char == '>'
            print(io, "&gt;")
        elseif char == '"'
            print(io, "&quot;")
        elseif char == '\''
            print(io, "&#39;")
        else
            print(io, char)
        end
    end
    return nothing
end

function escape_html(s::AbstractString)
    io = IOBuffer()
    escape_html(io, s)
    return String(take!(io))
end

"""
    format(io::IO, ::MIME"text/html", tokens, source, theme, language;
           mapping=default_capture_colors(), transform=default_transform, wrap=true,
           stylesheet=false, classprefix="hl", line_prefixes=Tuple{String,Int}[])

Format tokens as HTML.

Set `stylesheet=false` (default) for inline styles: `<span style="color: #hex">`.
Set `stylesheet=true` for CSS classes: `<span class="hl-c1">` (use with `stylesheet()`).
Set `classprefix` to customize the CSS class prefix (default "hl").
Set `wrap=false` to skip the `<pre>` wrapper (for preprocessed segments).
"""
function format(
    io::IO,
    mime::MIME"text/html",
    tokens::Vector{HighlightToken},
    source::AbstractString,
    theme::Theme,
    language::Symbol;
    mapping::Dict = default_capture_colors(),
    transform = default_transform,
    wrap::Bool = true,
    stylesheet::Bool = false,
    classprefix::AbstractString = "hl",
    line_prefixes::Vector{Tuple{String,Int}} = Tuple{String,Int}[],
)
    wrap && format_begin(io, mime, theme; stylesheet, classprefix)

    pos = 1
    line_idx = 0

    # Emit styled prefix for current line if present
    function emit_prefix()
        if line_idx <= length(line_prefixes)
            prefix, color = line_prefixes[line_idx]
            if !isempty(prefix)
                if stylesheet
                    print(io, "<span class=\"$(classprefix)-c$color\">")
                else
                    print(io, "<span style=\"color: $(theme.colors[color])\">")
                end
                escape_html(io, prefix)
                print(io, "</span>")
            end
        end
    end

    # Escape HTML text, interleaving line prefixes at newlines
    function escape_with_prefixes(text::AbstractString)
        if isempty(line_prefixes)
            # Fast path: no REPL prefixes
            escape_html(io, text)
        else
            # REPL path: interleave prefixes at newlines
            first = true
            for part in _eachsplit(text, '\n', keepempty = true)
                if !first
                    print(io, '\n')
                    line_idx += 1
                    emit_prefix()
                end
                first = false
                # Strip trailing \r for Windows line endings
                escape_html(io, rstrip(part, '\r'))
            end
        end
    end

    for token in tokens
        start_pos, end_pos = token.byte_range

        # Gap between tokens
        if pos < start_pos
            gap_text = SubString(source, pos, thisind(source, start_pos - 1))
            escape_with_prefixes(gap_text)
        end

        # Get color for token
        color_idx = get_capture_color(token.capture, mapping)

        # Write colored token with transform wrapper
        # Strip \r from token text (Windows CRLF creates empty tokens)
        token_text = replace(token.text, '\r' => "")
        if !isempty(token_text)
            transform(io, mime, token, true, source, language)
            if stylesheet
                print(io, "<span class=\"$(classprefix)-c$color_idx\">")
            else
                hex_color = theme.colors[color_idx]
                print(io, "<span style=\"color: $(hex_color)\">")
            end
            escape_with_prefixes(token_text)
            print(io, "</span>")
            transform(io, mime, token, false, source, language)
        end

        pos = end_pos + 1
    end

    # Remaining text after last token
    if pos <= ncodeunits(source)
        remaining = SubString(source, pos)
        escape_with_prefixes(remaining)
    end

    wrap && format_end(io, mime, theme)

    return nothing
end

"""
    format_styled(io::IO, ::MIME"text/html", text::AbstractString, color::Int, theme::Theme;
                  stylesheet=false, classprefix="hl")

Output text with a single color for HTML.
Color 0 uses theme foreground, 1-16 use theme.colors.
"""
function format_styled(
    io::IO,
    ::MIME"text/html",
    text::AbstractString,
    color::Int,
    theme::Theme;
    stylesheet::Bool = false,
    classprefix::AbstractString = "hl",
)
    if stylesheet
        if color == 0
            # No class for foreground
            escape_html(io, text)
            return nothing
        end
        print(io, "<span class=\"$(classprefix)-c$color\">")
    else
        hex = color == 0 ? theme.foreground : theme.colors[color]
        print(io, "<span style=\"color: $(hex)\">")
    end
    escape_html(io, text)
    print(io, "</span>")
    return nothing
end

function format_begin(
    io::IO,
    ::MIME"text/html",
    theme::Theme;
    stylesheet::Bool = false,
    classprefix::AbstractString = "hl",
)
    if stylesheet
        print(io, "<pre class=\"$(classprefix)\">")
    else
        print(
            io,
            "<pre style=\"background-color: $(theme.background); color: $(theme.foreground); padding: 1em; border-radius: 4px; overflow-x: auto;\">",
        )
    end
end

format_end(io::IO, ::MIME"text/html", ::Theme) = print(io, "</pre>")
