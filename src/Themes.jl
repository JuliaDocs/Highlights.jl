"""
A submodule that provides a selection of themes that can be used to colourise source code.

$(EXPORTS)
"""
module Themes

using DocStringExtensions

import ..Highlights: Str, AbstractTheme, AbstractLexer, definition


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

"""
$(TYPEDEF)

Represents a "compiled" colour scheme as constructed by [`build_theme`](@ref). Not a
user-facing type.
"""
immutable Theme
    base::Style
    style::Dict{UInt, Style}
    names::Dict{UInt, Symbol}
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


# Theme builder.

"""
Build a colour scheme `Theme` object based on a user-defined theme and lexer.
"""
@generated function build_theme{T <: AbstractTheme, L <: AbstractLexer}(::Type{T}, ::Type{L})
    local def = definition(T)
    local base = get(def, :style, S"")
    local style = get(def, :tokens, Dict{Symbol, Style}())
    local par = Dict{UInt, UInt}()
    local rev = Dict{UInt, Symbol}()
    # Parent tokens for all tokens used in the lexer `L`.
    for each in tokens(L)
        parent!(par, rev, each)
    end
    # Style dict and parents of all tokens defined in theme `T`.
    local sty = Dict{UInt, Style}()
    for (k, v) in style
        parent!(par, rev, k)
        sty[hash(k)] = v
    end
    # Calculate the 'fallback' style to use for each token if not defined.
    for (k, v) in par
        _k = k
        while true
            if haskey(sty, _k)
                sty[k] = sty[_k]
                break
            else
                _k = par[_k]
            end
        end
    end
    return Theme(base, sty, rev)
end

function parent!(d::Dict, rev::Dict, s::Symbol)
    local p = Symbol(join(split(string(s), '_')[1:end-1]))
    p = p === Symbol("") ? :text : (parent!(d, rev, p); p)
    rev[hash(s)] = s; rev[hash(p)] = p
    d[hash(s)] = hash(p)
    return p
end

tokens{L <: AbstractLexer}(::Type{L}) = tokens!(Set{Symbol}(), Set{DataType}(), L)

function tokens!{L <: AbstractLexer}(ts::Set{Symbol}, seen::Set{DataType}, ::Type{L})
    if !(L in seen)
        push!(seen, L)
        for (state, rules) in get(definition(L), :tokens, Dict())
            for rule in rules
                tokens!(ts, seen, rule)
            end
        end
    end
    return ts
end

tokens!(ts::Set, seen::Set, tup::Union{NTuple{2}, NTuple{3}}) = _tokens!(ts, seen, tup[2])
tokens!(ts::Set, ::Set, ::Symbol) = ts

function _tokens!(ts::Set, seen::Set, group::Tuple)
    for each in group
        _tokens!(ts, seen, each)
    end
    return ts
end
_tokens!(ts::Set, seen::Set, s::Symbol) = push!(ts, s)
_tokens!{L <: AbstractLexer}(ts::Set, seen::Set, ::Type{L}) = tokens!(ts, seen, L)

end # module
