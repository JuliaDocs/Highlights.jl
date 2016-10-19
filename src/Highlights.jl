__precompile__(true)

module Highlights

const Str = all(s -> isdefined(Core, s), (:String, :AbstractString)) ? String : UTF8String


# Lexer and Theme abstract interface.

abstract AbstractLexer
abstract AbstractTheme

definition{L <: AbstractLexer}(::Type{L}) = Dict{Symbol, Any}()
definition{T <: AbstractTheme}(::Type{T}) = Dict{Symbol, Any}()


# Submodules.

include("Compiler.jl")
include("Themes.jl")
include("Lexers.jl")
include("Format.jl")


# Public interface.

export highlight, stylesheet

function highlight{
        L <: AbstractLexer,
        T <: AbstractTheme,
    }(
        io::IO, mime::MIME, src::AbstractString,
        ::Type{L}, ::Type{T} = Themes.DefaultTheme,
    )
    local ctx = Compiler.lex(src, L)
    local theme = Themes.build_theme(T, L)
    Format.render(io, mime, ctx, theme)
end

function stylesheet{
        L <: AbstractLexer,
        T <: AbstractTheme,
    }(
        io::IO, mime::MIME,
        ::Type{L}, ::Type{T} = Themes.DefaultTheme
    )
    local theme = Themes.build_theme(T, L)
    Format.render(io, mime, theme)
end

end # module
