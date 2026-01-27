"""
    escape_latex(io::IO, s::AbstractString)
    escape_latex(s::AbstractString) -> String

Escape LaTeX special characters.
"""
function escape_latex(io::IO, s::AbstractString)
    for char in s
        if char == '\\'
            print(io, "\\textbackslash{}")
        elseif char == '{'
            print(io, "\\{")
        elseif char == '}'
            print(io, "\\}")
        elseif char == '$'
            print(io, "\\\$")
        elseif char == '%'
            print(io, "\\%")
        elseif char == '#'
            print(io, "\\#")
        elseif char == '&'
            print(io, "\\&")
        elseif char == '_'
            print(io, "\\_")
        elseif char == '^'
            print(io, "\\textasciicircum{}")
        elseif char == '~'
            print(io, "\\textasciitilde{}")
        elseif char == '`'
            print(io, "\\textasciigrave{}")
        elseif char == '\''
            print(io, "\\textquotesingle{}")
        else
            print(io, char)
        end
    end
    return nothing
end

function escape_latex(s::AbstractString)
    io = IOBuffer()
    escape_latex(io, s)
    return String(take!(io))
end

"""
    hex_to_latex_color(hex::AbstractString) -> String

Convert hex color to LaTeX RGB color specification.
"""
function hex_to_latex_color(hex::AbstractString)
    r, g, b = hex_to_rgb(hex)
    return "[RGB]{$r,$g,$b}"
end

"""
    format(io::IO, ::MIME"text/latex", tokens, source, theme, language;
           mapping=default_capture_colors(), transform=default_transform, wrap=true,
           stylesheet=false, classprefix="hl", line_prefixes=Tuple{String,Int}[])

Format tokens as LaTeX with color commands.

Set `stylesheet=false` (default) for inline colors: `\\textcolor[RGB]{...}{text}`.
Set `stylesheet=true` for stylesheet commands: `\\HLC1{text}` (use with `stylesheet()`).
Set `classprefix` to customize the command prefix (default "hl", commands become `\\HLC1`).
Set `wrap=false` to skip the lstlisting wrapper (for preprocessed segments).
"""
function format(
    io::IO,
    mime::MIME"text/latex",
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
    wrap && format_begin(io, mime, theme; stylesheet)

    cmdprefix = uppercase(classprefix) * "C"
    pos = 1
    line_idx = 0

    # Emit styled prefix for current line if present
    function emit_prefix()
        if line_idx <= length(line_prefixes)
            prefix, color = line_prefixes[line_idx]
            if !isempty(prefix)
                if stylesheet
                    print(io, "(*@\\", cmdprefix, color_to_letter(color), "{")
                else
                    latex_color = hex_to_latex_color(theme.colors[color])
                    print(io, "(*@\\textcolor", latex_color, "{")
                end
                escape_latex(io, prefix)
                print(io, "}@*)")
            end
        end
    end

    # Print raw text (for gaps/remaining), interleaving prefixes at newlines
    function print_raw(text::AbstractString)
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

    # Escape text for LaTeX, interleaving prefixes at newlines
    function escape_with_prefixes(text::AbstractString)
        if isempty(line_prefixes)
            escape_latex(io, text)
        else
            first = true
            for part in _eachsplit(text, '\n', keepempty = true)
                if !first
                    print(io, '\n')
                    line_idx += 1
                    emit_prefix()
                end
                first = false
                escape_latex(io, rstrip(part, '\r'))
            end
        end
    end

    for token in tokens
        start_pos, end_pos = token.byte_range

        # Gap between tokens
        if pos < start_pos
            gap_text = SubString(source, pos, thisind(source, start_pos - 1))
            print_raw(gap_text)
        end

        # Get color for token
        color_idx = get_capture_color(token.capture, mapping)

        # Write colored token with transform wrapper (using escapeinside)
        # Strip \r from token text (Windows CRLF creates empty tokens)
        token_text = replace(token.text, '\r' => "")
        if !isempty(token_text)
            transform(io, mime, token, true, source, language)
            if stylesheet
                print(io, "(*@\\", cmdprefix, color_to_letter(color_idx), "{")
            else
                hex_color = theme.colors[color_idx]
                latex_color = hex_to_latex_color(hex_color)
                print(io, "(*@\\textcolor", latex_color, "{")
            end
            escape_with_prefixes(token_text)
            print(io, "}@*)")
            transform(io, mime, token, false, source, language)
        end

        pos = end_pos + 1
    end

    # Remaining text after last token
    if pos <= ncodeunits(source)
        remaining = SubString(source, pos)
        print_raw(remaining)
    end

    wrap && format_end(io, mime, theme; stylesheet)

    return nothing
end

"""
    format_styled(io::IO, ::MIME"text/latex", text::AbstractString, color::Int, theme::Theme;
                  stylesheet=false, classprefix="hl")

Output text with a single color for LaTeX.
Color 0 uses theme foreground, 1-16 use theme.colors.
"""
function format_styled(
    io::IO,
    ::MIME"text/latex",
    text::AbstractString,
    color::Int,
    theme::Theme;
    stylesheet::Bool = false,
    classprefix::AbstractString = "hl",
)
    if stylesheet
        if color == 0
            # No command for foreground, just escape the text
            print(io, "(*@")
            escape_latex(io, text)
            print(io, "@*)")
            return nothing
        end
        cmdprefix = uppercase(classprefix) * "C"
        print(io, "(*@\\", cmdprefix, color_to_letter(color), "{")
    else
        hex = color == 0 ? theme.foreground : theme.colors[color]
        latex_color = hex_to_latex_color(hex)
        print(io, "(*@\\textcolor", latex_color, "{")
    end
    escape_latex(io, text)
    print(io, "}@*)")
    return nothing
end

function format_begin(
    io::IO,
    ::MIME"text/latex",
    theme::Theme;
    stylesheet::Bool = false,
    classprefix::AbstractString = "hl",
)
    if stylesheet
        # Stylesheet mode: use tcolorbox environment defined in stylesheet()
        println(io, "\\begin{$(classprefix)code}")
    else
        # Inline mode: definecolor + tcblisting (user provides packages in preamble)
        r, g, b = hex_to_rgb(theme.background)
        println(io, "\\definecolor{hlbg}{RGB}{$r,$g,$b}")
        r, g, b = hex_to_rgb(theme.foreground)
        println(io, "\\definecolor{hlfg}{RGB}{$r,$g,$b}")
        println(io)
        println(io, "\\begin{tcblisting}{")
        println(io, "  colback=hlbg,")
        println(io, "  colframe=hlbg,")
        println(io, "  listing only,")
        println(io, "  breakable,")
        println(io, "  boxrule=0pt,")
        println(io, "  left=0.5em,")
        println(io, "  right=0.5em,")
        println(io, "  top=0.5em,")
        println(io, "  bottom=0.5em,")
        println(io, "  listing options={")
        println(io, "    basicstyle=\\ttfamily\\footnotesize\\color{hlfg},")
        println(io, "    breaklines=true,")
        println(io, "    columns=fullflexible,")
        println(io, "    keepspaces=true,")
        println(io, "    showspaces=false,")
        println(io, "    showstringspaces=false,")
        println(io, "    escapeinside={(*@}{@*)},")
        println(io, "  }")
        println(io, "}")
    end
end

function format_end(
    io::IO,
    ::MIME"text/latex",
    ::Theme;
    stylesheet::Bool = false,
    classprefix::AbstractString = "hl",
)
    println(io)
    if stylesheet
        print(io, "\\end{$(classprefix)code}")
    else
        print(io, "\\end{tcblisting}")
    end
end
