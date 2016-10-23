"""
An exported submodule that provides a selection of lexer definitions for tokenising source
code. The following lexers are exported from the module:

$(EXPORTS)
"""
module Lexers

using DocStringExtensions

import ..Highlights: AbstractLexer, definition


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
    JuliaLexer

"A lexer for Julia source code."
abstract JuliaLexer <: AbstractLexer


# Definitions.

include("lexers/julia.jl")

end # module