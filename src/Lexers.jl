module Lexers

import ..Highlights: AbstractLexer, definition


# Utilities.

words(vec; prefix="", suffix="") = Regex(string(prefix, "(", join(vec, '|'), ")", suffix))

macro raw_str(str)
    str
end


# Names.

export
    JuliaLexer

abstract JuliaLexer <: AbstractLexer


# Definitions.

include("lexers/julia.jl")

end # module
