"""
    write_typst_str(io::IO, s::AbstractString)

Write string as Typst raw string `#"..."` preserving whitespace.
"""
function write_typst_str(io::IO, s::AbstractString)
    r = repr(String(s))
    # Undo \$ escaping - Typst strings don't need it
    print(io, "#", replace(r, "\\\$" => raw"$"))
end

# Legacy API for tests
escape_typst(s::AbstractString) = sprint(write_typst_str, s)

"""
    write_typst_raw(io::IO, s::AbstractString)

Write text as Typst raw content `#raw("...")` which preserves whitespace.
"""
function write_typst_raw(io::IO, s::AbstractString)
    print(io, "#raw(")
    r = repr(String(s))
    print(io, replace(r, "\\\$" => raw"$"))
    print(io, ")")
end

"""
    format(io::IO, ::MIME"text/typst", tokens, source, theme, language;
           mapping=default_capture_colors(), transform=default_transform, wrap=true,
           line_prefixes=Tuple{String,Int}[])

Format tokens as Typst markup with colored text.
Set `wrap=false` to skip the block wrapper (for preprocessed segments).
"""
function format(
    io::IO,
    mime::MIME"text/typst",
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
    wrap && format_begin(io, mime, theme)

    pos = 1
    line_idx = 0

    # Emit styled prefix for current line if present
    function emit_prefix()
        if line_idx <= length(line_prefixes)
            prefix, color = line_prefixes[line_idx]
            if !isempty(prefix)
                r, g, b = hex_to_rgb(theme.colors[color])
                print(io, "#text(fill: rgb($r, $g, $b))[")
                write_typst_raw(io, prefix)
                print(io, "]")
            end
        end
    end

    # Write text with proper line break handling
    # text_open: opening sequence for the styled wrapper(s) — close with as many "]" as
    #   open brackets in text_open. Empty string means no wrapper.
    # in_wrap: true if we're currently inside the wrapper brackets
    # Returns true if we ended inside the wrapper
    function write_text(
        text::AbstractString,
        text_open::AbstractString = "",
        bracket_count::Int = 0,
        in_wrap::Bool = false,
    )
        lines = split(text, '\n', keepempty = true)
        for (i, line) in enumerate(lines)
            if i > 1
                # Close wrapper brackets before newline if we're inside
                if in_wrap
                    for _ = 1:bracket_count
                        print(io, "]")
                    end
                end
                print(io, " \\\n")  # Typst line break: backslash-space
                line_idx += 1
                emit_prefix()
                # Reopen wrapper after newline
                if !isempty(text_open)
                    print(io, text_open)
                    in_wrap = true
                else
                    in_wrap = false
                end
            end
            line = rstrip(line, '\r')
            if !isempty(line)
                write_typst_raw(io, line)
            end
        end
        return in_wrap
    end

    for token in tokens
        start_pos, end_pos = token.byte_range

        # Gap between tokens
        if pos < start_pos
            gap_text = SubString(source, pos, thisind(source, start_pos - 1))
            write_text(gap_text)
        end

        # Get color and styles for token
        color_idx = get_capture_color(token.capture, mapping)
        r, g, b = hex_to_rgb(theme.colors[color_idx])
        styles = get_capture_styles(token.capture, theme)

        # Build the #text(...) call with weight/style kwargs
        text_args = "fill: rgb($r, $g, $b)"
        if :bold in styles
            text_args *= ", weight: \"bold\""
        end
        if :italic in styles
            text_args *= ", style: \"italic\""
        end
        underline_wrap = :underline in styles

        text_open = underline_wrap ? "#underline[#text($text_args)[" : "#text($text_args)["
        bracket_count = underline_wrap ? 2 : 1

        # Write colored token with transform wrapper
        # Strip \r from token text (Windows CRLF creates empty tokens)
        token_text = replace(token.text, '\r' => "")
        if !isempty(token_text)
            transform(io, mime, token, true, source, language)
            print(io, text_open)
            still_in_wrap = write_text(token_text, text_open, bracket_count, true)
            if still_in_wrap
                for _ = 1:bracket_count
                    print(io, "]")
                end
            end
            transform(io, mime, token, false, source, language)
        end

        pos = end_pos + 1
    end

    # Remaining text after last token
    if pos <= ncodeunits(source)
        remaining = SubString(source, pos)
        write_text(remaining)
    end

    wrap && format_end(io, mime, theme)

    return nothing
end

"""
    format_styled(io::IO, ::MIME"text/typst", text::AbstractString, color::Int, theme::Theme)

Output text with a single color for Typst.
Color 0 uses theme foreground, 1-16 use theme.colors. Used by the line-prefix
path (REPL session preprocessors); line prefixes carry no per-capture styling.
"""
function format_styled(
    io::IO,
    ::MIME"text/typst",
    text::AbstractString,
    color::Int,
    theme::Theme;
    stylesheet::Bool = false,
    classprefix::AbstractString = "hl",
)
    hex = color == 0 ? theme.foreground : theme.colors[color]
    r, g, b = hex_to_rgb(hex)
    print(io, "#text(fill: rgb($r, $g, $b))[")
    write_typst_raw(io, text)
    print(io, "]")
    return nothing
end

function format_begin(
    io::IO,
    ::MIME"text/typst",
    theme::Theme;
    stylesheet::Bool = false,
    classprefix::AbstractString = "hl",
)
    r, g, b = hex_to_rgb(theme.background)
    fr, fg, fb = hex_to_rgb(theme.foreground)
    println(io, "#block(fill: rgb($r, $g, $b), inset: 1em, radius: 4pt, width: 100%)[")
    println(
        io,
        "#set text(font: \"DejaVu Sans Mono\", size: 9pt, fill: rgb($fr, $fg, $fb))",
    )
    println(io, "#set par(leading: 0.5em)")
end

function format_end(io::IO, ::MIME"text/typst", ::Theme)
    print(io, "]")
end
