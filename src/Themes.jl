"""
A submodule that provides a selection of themes that can be used to colourise source code.

$(EXPORTS)
"""
module Themes

using DocStringExtensions

import ..Highlights: Str, AbstractTheme, AbstractLexer

# Public interface.

export AbstractTheme, @S_str, @theme

# Style and Theme types.

const NULL_STRING = Str("")

"""
$(TYPEDEF)

An internal type used to track colour scheme definition information such as foreground and
background colours as well as bold, italic, and underlining.
"""
immutable Style
    fg::Str
    bg::Str
    bold::Bool
    italic::Bool
    underline::Bool

    function Style(spec::AbstractString)
        fg = bg = NULL_STRING
        bold = italics = underline = false
        for part in split(spec, r"\s*;\s*")
            startswith(part, "fg:") && (fg = strip(part[4:end]))
            startswith(part, "bg:") && (bg = strip(part[4:end]))
            part == "bold" && (bold = true)
            part == "italic" && (italics = true)
            part == "underline" && (underline = true)
        end
        return new(expand_html(fg), expand_html(bg), bold, italics, underline)
    end
end

"""
$(SIGNATURES)

Expands an HTML colour code `s` from 3 digits to 6.
"""
expand_html(s::AbstractString) = length(s) == 3 ? join(map(join, zip(s, s))) : s

"""
$(SIGNATURES)

Does the [`Style`](@ref) `s` have a foreground colour set?
"""
has_fg(s::Style) = s.fg !== NULL_STRING

"""
$(SIGNATURES)

Does the [`Style`](@ref) `s` have a background colour set?
"""
has_bg(s::Style) = s.bg !== NULL_STRING

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
immutable Theme
    base::Style
    styles::Vector{Style}
    Theme(base::Style, n::Integer) = new(base, Vector{Style}(n))
end

function metadata end
function theme end

function maketheme(T)
    local dict = metadata(T)
    local n = length(Tokens.__TOKENS__)
    local theme = Theme(get(dict, :style, S""), n)
    local styles = get(dict, :tokens, Dict{Tokens.TokenValue, Style}())
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

julia> abstract CustomTheme <: AbstractTheme

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
    PygmentsTheme,
    TangoTheme,
    TracTheme,
    VimTheme,
    VisualStudioTheme,
    XcodeTheme

"The default colour scheme with colours based on the Julia logo."
abstract DefaultTheme <: AbstractTheme

"A theme based on the Emacs colour scheme."
abstract EmacsTheme <: AbstractTheme
"A GitHub inspired colour scheme."
abstract GitHubTheme <: AbstractTheme
"A colour scheme similar to the Monokai theme."
abstract MonokaiTheme <: AbstractTheme
"Based on the default colour scheme used by the Pygments highlighter."
abstract PygmentsTheme <: AbstractTheme
"A Tango-inspired colour scheme."
abstract TangoTheme <: AbstractTheme
"Based on the default trac highlighter."
abstract TracTheme <: AbstractTheme
"A Vim 7.0 based colour scheme."
abstract VimTheme <: AbstractTheme
"A theme based on the default Visual Studio colours."
abstract VisualStudioTheme <: AbstractTheme
"A theme based on the default Xcode colour scheme."
abstract XcodeTheme <: AbstractTheme


# Theme definitions.

using ..Highlights.Tokens

include("themes/default.jl")

include("themes/pygments.jl")
include("themes/emacs.jl")
include("themes/github.jl")
include("themes/monokai.jl")
include("themes/tango.jl")
include("themes/trac.jl")
include("themes/vim.jl")
include("themes/vs.jl")
include("themes/xcode.jl")

end # module
