"""
    format(io::IO, ::MIME"text/plain", tokens, source, theme, language;
           transform=default_transform, line_prefixes=Tuple{String,Int}[])

Format tokens as plain text with capture names in brackets.
Useful for debugging highlighting queries.
"""
function format(
    io::IO,
    mime::MIME"text/plain",
    tokens::Vector{HighlightToken},
    source::AbstractString,
    ::Theme,
    language::Symbol;
    transform = default_transform,
    wrap::Bool = true,
    stylesheet::Bool = false,
    classprefix::AbstractString = "hl",
    line_prefixes::Vector{Tuple{String,Int}} = Tuple{String,Int}[],
)
    pos = 1
    line_idx = 0

    # Emit prefix for current line if present
    function emit_prefix()
        if line_idx <= length(line_prefixes)
            prefix, _ = line_prefixes[line_idx]
            print(io, prefix)
        end
    end

    # Print text, interleaving prefixes at newlines
    function print_text(text::AbstractString)
        if isempty(line_prefixes)
            print(io, text)
        else
            first = true
            for part in _eachsplit(text, '\n', keepempty = true)
                if !first
                    print(io, '\n')
                    line_idx += 1
                    emit_prefix()
                end
                first = false
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

        # Write token with capture name and transform wrapper
        # Strip \r from token text (Windows CRLF creates empty tokens)
        token_text = replace(token.text, '\r' => "")
        if !isempty(token_text)
            transform(io, mime, token, true, source, language)
            print(io, "[", token.capture, ":")
            print_text(token_text)
            print(io, "]")
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
    format_styled(io::IO, ::MIME"text/plain", text::AbstractString, color::Int, theme::Theme)

Output text without styling for plain format.
"""
function format_styled(
    io::IO,
    ::MIME"text/plain",
    text::AbstractString,
    ::Int,
    ::Theme;
    stylesheet::Bool = false,
    classprefix::AbstractString = "hl",
)
    print(io, text)
    return nothing
end

format_begin(
    ::IO,
    ::MIME"text/plain",
    ::Theme;
    stylesheet::Bool = false,
    classprefix::AbstractString = "hl",
) = nothing
format_end(::IO, ::MIME"text/plain", ::Theme) = nothing
