module Themes

import ..Highlights: Str, AbstractTheme, AbstractLexer, definition


# Style and Theme types.

const NULL_STRING = ""

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

expand_html(s::AbstractString) = length(s) == 3 ? join(map(join, zip(s, s))) : s

has_fg(s::Style) = s.fg !== NULL_STRING
has_bg(s::Style) = s.bg !== NULL_STRING

macro S_str(spec)
    Style(spec)
end

immutable Theme
    base::Style
    style::Dict{UInt, Style}
    names::Dict{UInt, Symbol}
end


# Theme names.

export
    DefaultTheme,
    GitHubTheme,
    MonokaiTheme,
    XcodeTheme

abstract DefaultTheme <: AbstractTheme
abstract GitHubTheme <: AbstractTheme
abstract MonokaiTheme <: AbstractTheme
abstract XcodeTheme <: AbstractTheme


# Theme definitions.

include("themes/default.jl")
include("themes/github.jl")
include("themes/monokai.jl")
include("themes/xcode.jl")


# Theme builder.

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
