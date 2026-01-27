# ANSI escape code utilities for terminal color output.

"""
    hex_to_rgb(hex::AbstractString) -> Tuple{Int,Int,Int}

Convert a hex color string (e.g., "#DB2D20" or "DB2D20") to RGB tuple.
"""
function hex_to_rgb(hex::AbstractString)
    hex = lstrip(hex, '#')
    r = parse(Int, hex[1:2], base = 16)
    g = parse(Int, hex[3:4], base = 16)
    b = parse(Int, hex[5:6], base = 16)
    return (r, g, b)
end

const HEX_CHARS =
    ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F')

"""
    rgb_to_hex(r::Int, g::Int, b::Int) -> String

Convert RGB values to a hex color string (e.g., "#DB2D20").
"""
function rgb_to_hex(r::Int, g::Int, b::Int)
    return string(
        '#',
        HEX_CHARS[(r>>4)+1],
        HEX_CHARS[(r&0xf)+1],
        HEX_CHARS[(g>>4)+1],
        HEX_CHARS[(g&0xf)+1],
        HEX_CHARS[(b>>4)+1],
        HEX_CHARS[(b&0xf)+1],
    )
end

"""
    ansi_color_rgb(r::Int, g::Int, b::Int; background::Bool=false) -> String

Generate ANSI 24-bit true color escape sequence.
"""
function ansi_color_rgb(r::Int, g::Int, b::Int; background::Bool = false)
    code = background ? 48 : 38
    return "\e[$(code);2;$(r);$(g);$(b)m"
end

"""
    ansi_reset() -> String

Return ANSI reset escape sequence to clear all formatting.
"""
ansi_reset() = "\e[0m"

"""
    ansi_color_from_hex(hex::AbstractString; background::Bool=false) -> String

Generate ANSI 24-bit true color escape sequence from hex color string.
"""
function ansi_color_from_hex(hex::AbstractString; background::Bool = false)
    r, g, b = hex_to_rgb(hex)
    return ansi_color_rgb(r, g, b; background = background)
end

# Convert color index (1-16) to letter (a-p) for LaTeX command names
color_to_letter(i::Int) = Char('a' + i - 1)

# Compat shim for eachsplit (added in Julia 1.8)
@static if VERSION >= v"1.8"
    _eachsplit(text, delim; keepempty) = eachsplit(text, delim; keepempty)
else
    _eachsplit(text, delim; keepempty) = split(text, delim; keepempty)
end
