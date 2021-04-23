"""
An exported submodule that provides a selection of lexer definitions for tokenising source
code. The following names are exported from the module:

$(EXPORTS)
"""
module Lexers

using DocStringExtensions

import ..Highlights: AbstractLexer
import ..Highlights.Compiler

# Public Interface.

export  AbstractLexer, @lexer

"""
$(SIGNATURES)

Declare the lexer definition for a custom lexer `T` using a `Dict` object `dict`. `dict`
must either be a `Dict` literal or an expression that returns a `Dict` -- such as a `let`
block.

# Examples

```jldoctest
julia> using Highlights.Lexers

julia> abstract type CustomLexer <: AbstractLexer end

julia> @lexer CustomLexer Dict(
           :name => "Custom",
           :tokens => Dict(
               # ...
           )
       );

```
"""
macro lexer(T, dict)
    tx, dx = map(esc, (T, dict))
    quote
        let data = $(Compiler).LexerData($dx)
            $(Compiler).metadata(::Type{$tx}) = data
        end
        # let data = getdata($tx)
        #     @generated $(Compiler).lex!{S}(ctx::Context, ::Type{$tx}, ::State{S}) =
        #         compile($tx, S, data)
        # end
        $(Compiler).compile_lexer($(__module__), $tx)
        $tx
    end
end

# Utilities.

"""
$(SIGNATURES)

Build a regular expression from a vector of strings. Useful for keyword lists.

The keyword arguments `prefix` and `suffix` can be used to add patterns before and after the
main match group.

# Examples

```jldoctest
julia> import Highlights.Lexers: words

julia> words(["if", "else"])
r"(if|else)"
```
"""
words(vec; prefix="", suffix="") = Regex(string(prefix, "(", join(vec, '|'), ")", suffix))

"""
$(SIGNATURES)

A utility string macro to avoid having to escape strings used to build a regular expression.
"""
macro raw_str(str)
    str
end


# Names.

export
    FortranLexer,
    JuliaLexer,
    JuliaConsoleLexer,
    MatlabLexer,
    RLexer,
    TOMLLexer

"A FORTRAN 90 source code lexer."
abstract type FortranLexer <: AbstractLexer end
"A lexer for Julia source code."
abstract type JuliaLexer <: AbstractLexer end
"A lexer for Julia REPL sessions."
abstract type JuliaConsoleLexer <: AbstractLexer end
"A lexer for MATLAB source code."
abstract type MatlabLexer <: AbstractLexer end
"A lexer for the R language."
abstract type RLexer <: AbstractLexer end
"TOML (Tom's Obvious, Minimal Language) lexer."
abstract type TOMLLexer <: AbstractLexer end


# Definitions.

using ..Highlights.Tokens

include("lexers/fortran.jl")
include("lexers/julia.jl")
include("lexers/matlab.jl")
include("lexers/r.jl")
include("lexers/toml.jl")

end # module
