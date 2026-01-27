"""
    format(io::IO, ::MIME"text/ansi", tokens, source, theme, language;
           mapping=default_capture_colors(), transform=default_transform, wrap=true,
           line_prefixes=Tuple{String,Int}[])

Format tokens with ANSI color codes for terminal output.
The `wrap` parameter is accepted for API consistency but ignored (ANSI has no wrapper).
"""
function format(
    io::IO,
    mime::MIME"text/ansi",
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
    pos = 1
    line_idx = 0

    # Emit styled prefix for current line if present
    function emit_prefix()
        if line_idx <= length(line_prefixes)
            prefix, color = line_prefixes[line_idx]
            if !isempty(prefix)
                hex = theme.colors[color]
                print(io, ansi_color_from_hex(hex), prefix, ansi_reset())
            end
        end
    end

    # Print text, interleaving line prefixes at newlines
    # restore_color: ANSI code to re-apply after prefix (since prefix resets)
    function print_text(text::AbstractString, restore_color::AbstractString = "")
        if isempty(line_prefixes)
            # Fast path: no REPL prefixes
            print(io, text)
        else
            # REPL path: interleave prefixes at newlines
            first = true
            for part in _eachsplit(text, '\n'; keepempty = true)
                if !first
                    print(io, '\n')
                    line_idx += 1
                    emit_prefix()
                    print(io, restore_color)  # Re-apply color after prefix reset
                end
                first = false
                # Strip trailing \r for Windows line endings
                print(io, rstrip(part, '\r'))
            end
        end
    end

    for token in tokens
        start_pos, end_pos = token.byte_range

        # Gap between tokens
        if pos < start_pos
            gap_text = SubString(source, pos, thisind(source, start_pos - 1))
            print_text(gap_text)
        end

        # Get color for token
        color_idx = get_capture_color(token.capture, mapping)
        hex_color = theme.colors[color_idx]
        color_code = ansi_color_from_hex(hex_color)

        # Write colored token with transform wrapper
        # Strip \r from token text (Windows CRLF creates empty tokens)
        token_text = replace(token.text, '\r' => "")
        if !isempty(token_text)
            transform(io, mime, token, true, source, language)
            print(io, color_code)
            print_text(token_text, color_code)
            print(io, ansi_reset())
            transform(io, mime, token, false, source, language)
        end

        pos = end_pos + 1
    end

    # Remaining text after last token
    if pos <= ncodeunits(source)
        remaining = SubString(source, pos)
        print_text(remaining)
    end

    return nothing
end

"""
    format_styled(io::IO, ::MIME"text/ansi", text::AbstractString, color::Int, theme::Theme)

Output text with a single color for ANSI terminal.
Color 0 uses theme foreground, 1-16 use theme.colors.
"""
function format_styled(
    io::IO,
    ::MIME"text/ansi",
    text::AbstractString,
    color::Int,
    theme::Theme;
    stylesheet::Bool = false,
    classprefix::AbstractString = "hl",
)
    hex = color == 0 ? theme.foreground : theme.colors[color]
    print(io, ansi_color_from_hex(hex))
    print(io, text)
    print(io, ansi_reset())
    return nothing
end

format_begin(
    ::IO,
    ::MIME"text/ansi",
    ::Theme;
    stylesheet::Bool = false,
    classprefix::AbstractString = "hl",
) = nothing
format_end(::IO, ::MIME"text/ansi", ::Theme) = nothing
