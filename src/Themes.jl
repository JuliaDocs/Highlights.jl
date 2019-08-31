"""
A submodule that provides a selection of themes that can be used to colourise source code.

$(EXPORTS)
"""
module Themes

using DocStringExtensions

import ..Highlights: AbstractTheme, AbstractLexer

# Public interface.

export AbstractTheme, @S_str, @theme


# Colour, Style, Theme types.

"""
$(TYPEDEF)

Represents a single RGB colour value that can be 'active' or 'inactive'.
"""
struct RGB
    r::UInt8
    g::UInt8
    b::UInt8
    active::Bool

    function RGB(str::AbstractString)
        n = length(str)
        r, g, b = n == 3 ? rgb3(str) : n == 6 ? rgb6(str) :
            error("invalid colour code. Must be a 3 or 6 digit hex value.")
        return new(r, g, b, true)
    end

    RGB() = new(0x00, 0x00, 0x00, false)
end

"Convert a three digit hex string to a 3-tuple of `UInt8`s."
function rgb3(str)
    r = parse(UInt8, str[1], base=16)
    g = parse(UInt8, str[2], base=16)
    b = parse(UInt8, str[3], base=16)
    return (r << 4 + r, g << 4 + g, b << 4 + b)
end

"Convert a six digit hex string to a 3-tuple of `UInt8`s."
function rgb6(str)
    r1 = parse(UInt8, str[1], base=16)
    r2 = parse(UInt8, str[2], base=16)
    g1 = parse(UInt8, str[3], base=16)
    g2 = parse(UInt8, str[4], base=16)
    b1 = parse(UInt8, str[5], base=16)
    b2 = parse(UInt8, str[6], base=16)
    return (r1 << 4 + r2, g1 << 4 + g2, b1 << 4 + b2)
end


"""
$(TYPEDEF)

An internal type used to track colour scheme definition information such as foreground and
background colours as well as bold, italic, and underlining.
"""
struct Style
    fg::RGB
    bg::RGB
    bold::Bool
    italic::Bool
    underline::Bool

    function Style(spec::AbstractString)
        fg = bg = RGB()
        bold = italics = underline = false
        for part in split(spec, r"\s*;\s*")
            startswith(part, "fg:") && (fg = RGB(strip(part[4:end])))
            startswith(part, "bg:") && (bg = RGB(strip(part[4:end])))
            part == "bold" && (bold = true)
            part == "italic" && (italics = true)
            part == "underline" && (underline = true)
        end
        return new(fg, bg, bold, italics, underline)
    end
end

"""
$(SIGNATURES)

Construct a [`Style`](@ref) object.
"""
macro S_str(spec)
    Style(spec)
end

import ..Highlights.Tokens

"""
$(TYPEDEF)

Represents a "compiled" colour scheme.
"""
struct Theme
    base::Style
    styles::Vector{Style}
    Theme(base::Style, n::Integer) = new(base, Vector{Style}(undef, n))
end

function metadata end
function theme end

function maketheme(T)
    dict = metadata(T)
    n = length(Tokens.__TOKENS__)
    theme = Theme(get(dict, :style, S""), n)
    styles = get(dict, :tokens, Dict{Tokens.TokenValue, Style}())
    get!(styles, Tokens.TEXT, S"") # Set default TEXT if not already done.
    for (nth, t) in enumerate(Tokens.__TOKENS__)
        theme.styles[nth] = fallback(Tokens.__FALLBACKS__, styles, Tokens.TokenValue(t))
    end
    return theme
end

fallback(mapping, styles, token) = haskey(styles, token) ? styles[token] :
    fallback(mapping, styles, Tokens.TokenValue(mapping[token.value]))

"""
$(SIGNATURES)

Declare the theme definition for theme `T` based on `dict`. `dict` must be a `Dict` and `T`
must be a subtype of `AbstractTheme`.

# Examples

```jldoctest
julia> using Highlights.Themes

julia> abstract type CustomTheme <: AbstractTheme end

julia> @theme CustomTheme Dict(
           :name => "Custom",
           :tokens => Dict(
               # ...
           )
       );
```
"""
macro theme(T, dict)
    tx, dx = map(esc, (T, dict))
    quote
        $(Themes).metadata(::Type{$tx}) = $dx
        let data = $(Themes).maketheme($tx)
            $(Themes).theme(::Type{$tx}) = data::Theme
        end
    end
end

# Theme names.

export
    DefaultTheme,

    EmacsTheme,
    GitHubTheme,
    MonokaiTheme,
    MonokaiMiniTheme,
    PygmentsTheme,
    TangoTheme,
    TracTheme,
    VimTheme,
    VisualStudioTheme,
    XcodeTheme

"The default colour scheme with colours based on the Julia logo."
abstract type DefaultTheme <: AbstractTheme end

"A theme based on the Emacs colour scheme."
abstract type EmacsTheme <: AbstractTheme end
"A GitHub inspired colour scheme."
abstract type GitHubTheme <: AbstractTheme end
"A colour scheme similar to the Monokai theme."
abstract type MonokaiTheme <: AbstractTheme end
"A colour scheme similar to the Monokai theme that works on both light and dark backgrounds."
abstract type MonokaiMiniTheme <: AbstractTheme end
"Based on the default colour scheme used by the Pygments highlighter."
abstract type PygmentsTheme <: AbstractTheme end
"A Tango-inspired colour scheme."
abstract type TangoTheme <: AbstractTheme end
"Based on the default trac highlighter."
abstract type TracTheme <: AbstractTheme end
"A Vim 7.0 based colour scheme."
abstract type VimTheme <: AbstractTheme end
"A theme based on the default Visual Studio colours."
abstract type VisualStudioTheme <: AbstractTheme end
"A theme based on the default Xcode colour scheme."
abstract type XcodeTheme <: AbstractTheme end


# Theme definitions.

using ..Highlights.Tokens

include("themes/default.jl")

include("themes/pygments.jl")
include("themes/emacs.jl")
include("themes/github.jl")
include("themes/monokai.jl")
include("themes/monokaimini.jl")
include("themes/tango.jl")
include("themes/trac.jl")
include("themes/vim.jl")
include("themes/vs.jl")
include("themes/xcode.jl")

end # module
