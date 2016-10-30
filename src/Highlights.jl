__precompile__(true)

"""
**Highlights.jl** is a Julia package for source code highlighting. It provides a regular
expression based mechanism for creating lexers in a similar way to Pygments.

The following names are exported from the root module, `Highlights`, and are available for
external use. Note that unexported names are considered unstable and subject to change.

$(EXPORTS)
"""
module Highlights

using Compat, DocStringExtensions
const Str = all(s -> isdefined(Core, s), (:String, :AbstractString)) ? String : UTF8String


"""
$(TYPEDEF)

Represents a source code lexer used to tokenise text.
"""
abstract AbstractLexer

"""
$(TYPEDEF)

Represents a colour scheme used to highlight tokenised source code.
"""
abstract AbstractTheme

# Submodules.

include("Tokens.jl")
include("Compiler.jl")
include("Themes.jl")
include("Lexers.jl")
include("Format.jl")


"""
$(SIGNATURES)

Return the `AbstractLexer` associated with the lexer named `name`. `name` must be a string.
Internally this checks the `:aliases` field in the `definition` of a lexer to see whether it
is a match.

!!! warning

    This method is *not* type stable.

When no lexer matches the given `name` an `ArgumentError` is thrown.
"""
function lexer(name::AbstractString)
    for each in subtypes(AbstractLexer)
        local def = Compiler.metadata(each)
        name in def.aliases && return each
    end
    throw(ArgumentError("no lexer found with name '$name'."))
end


# Public interface.

export Lexers, Themes, Tokens, highlight, stylesheet, lexer

"""
Highlight source code using a specific lexer, mimetype and theme.

$(SIGNATURES)

`src` is tokenised using the provided `lexer`, then colourised using `theme`, and finally
output to `io` in the given format `mime`. `theme` defaults to `Themes.DefaultTheme` theme.

`mime` can be either of `MIME("text/html")` or `MIME("text/latex")`.

# Examples

```jldoctest
julia> using Highlights

julia> highlight(STDOUT, MIME("text/html"), "2x", Lexers.JuliaLexer)
<pre class='hljl'>
<span class='hljl-NUMBER_INTEGER'>2</span><span class='hljl-NAME'>x</span>
</pre>

julia> highlight(STDOUT, MIME("text/latex"), "'x'", Lexers.JuliaLexer, Themes.VimTheme)
\\begin{lstlisting}
(*@\\HLJLSTRINGCHAR{{\\textquotesingle}x{\\textquotesingle}}@*)
\\end{lstlisting}

```
"""
function highlight{
        L <: AbstractLexer,
        T <: AbstractTheme,
    }(
        io::IO, mime::MIME, src::AbstractString,
        lexer::Type{L}, theme::Type{T} = Themes.DefaultTheme,
    )
    Format.render(io, mime, Compiler.lex(src, L), Themes.theme(T))
end

"""
Generate a "stylesheet" for the given theme.

$(SIGNATURES)

Prints out the style information needed to colourise source code in the given
`theme`. Note that `theme` defaults to `Themes.DefaultTheme`. Output is printed
to `io` in the format `mime`. `mine` can be one of

  * `MIME("text/html")`
  * `MIME("text/css")`
  * `MIME("text/latex")`

# Examples

```jldoctest
julia> using Highlights

julia> buf = IOBuffer();

julia> stylesheet(buf, MIME("text/css"), Themes.EmacsTheme)

julia> split(takebuf_string(buf), '\\n')[1] # Too much output to show everything.
"pre.hljl {"

```
"""
stylesheet{T <: AbstractTheme}(io::IO, mime::MIME, theme::Type{T} = Themes.DefaultTheme) =
    Format.render(io, mime, Themes.theme(T))

end # module
