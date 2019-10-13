"""
The `Format` module provides a public interface that can be used to define custom formatters
aside from the predefined HTML and LaTeX outputs supported by `Highlights`.

The [Formatting](@ref) section of the manual provides a example of how to go about extending
`Highlights` to support additional output formats.

The following functions and types are exported from the module for public use:

$(EXPORTS)
"""
module Format

using DocStringExtensions

import ..Highlights
import ..Highlights.Compiler: Context
import ..Highlights.Themes: RGB, Style, Theme
import ..Highlights.Tokens

export TokenIterator, render

"""
The `render` function is used to define custom output formats for tokenised source code.
Methods with signatures of the form

```julia
function Format.render(io::IO, mime::MIME, tokens::Format.TokenIterator)
    # ...
    for (str, id, style) in tokens
        # ...
    end
    # ...
end
```

can be defined for any `mime` type to allow the [`highlight`](@ref Highlights.highlight)
function to support new output formats.
"""
function render end

# RGB colours.

render(io::IO, ::MIME"text/css", c::RGB) = (print(io, "rgb("); _tup(io, c); print(io, ")"))
render(io::IO, ::MIME"text/latex", c::RGB) = (print(io, "[RGB]{"); _tup(io, c); print(io, "}"))

_tup(io::IO, c::RGB) = print(io, Int(c.r), ",", Int(c.g), ",", Int(c.b))


# Styles.

function render(io::IO, mime::MIME"text/css", style::Style)
    if style.fg.active
        print(io, "color: ")
        render(io, mime, style.fg)
        print(io, "; ")
    end
    if style.bg.active
        print(io, "background-color: ")
        render(io, mime, style.bg)
        print(io, "; ")
    end
    style.bold      && print(io, "font-weight: bold; ")
    style.italic    && print(io, "font-style: italic; ")
    style.underline && print(io, "text-decoration: underline; ")
    return nothing
end

function render(io::IO, mime::MIME"text/latex", style::Style)
    print(io, "[1]{")
    if style.fg.active
        print(io, "\\textcolor")
        render(io, mime, style.fg)
        print(io, "{")
    end
    if style.bg.active
        print(io, "\\colorbox")
        render(io, mime, style.bg)
        print(io, "{")
    end
    style.bold      && print(io, "\\textbf{")
    style.italic    && print(io, "\\textit{")
    style.underline && print(io, "\\underline{")
    print(io, "#1")
    style.underline && print(io, "}")
    style.italic    && print(io, "}")
    style.bold      && print(io, "}")
    style.bg.active && print(io, "}")
    style.fg.active && print(io, "}")
    print(io, "}")
end


# Stylesheets.

function render(io::IO, mime::MIME"text/css", theme::Theme)
    print(io,
        """
        pre.hljl {
            border: 1px solid #ccc;
            margin: 5px;
            padding: 5px;
            overflow-x: auto;
            """
    )
    render(io, mime, theme.base)
    println(io, "}")
    for (nth, style) in enumerate(theme.styles)
        print(io, "pre.hljl > span.hljl-", Tokens.__SHORTNAMES__[nth], " { ")
        render(io, mime, style)
        println(io, "}")
    end
end

function render(io::IO, ::MIME"text/html", theme::Theme)
    println(io, "\n<style>")
    render(io, MIME"text/css"(), theme)
    println(io, "</style>\n")
end

function render(io::IO, mime::MIME"text/latex", theme::Theme)
    println(io, "\\usepackage{upquote}")
    println(io, "\\usepackage{listings}")
    println(io, "\\usepackage{xcolor}")
    print(io,
        """
        \\lstset{
            basicstyle=\\ttfamily\\footnotesize,
            upquote=true,
            breaklines=true,
            breakindent=0pt,
            keepspaces=true,
            showspaces=false,
            columns=fullflexible,
            showtabs=false,
            showstringspaces=false,
            escapeinside={(*@}{@*)},
            extendedchars=true,
        }
        """
    )
    for (nth, style) in enumerate(theme.styles)
        print(io, "\\newcommand{\\HLJL", Tokens.__SHORTNAMES__[nth], "}")
        render(io, mime, style)
        println(io)
    end
end

# Token Iterator.

"""
$(TYPEDEF)

An iterator type used in user-defined [`render`](@ref) methods to provide custom output
formats. This type supports the basic Julia iterator protocol: namely `iterate` which enables `for`-loop interation over tokenised text.

The iterator returns a 3-tuple of `str`, `id`, and `style` where

  * `str` is the `SubString` covered by the token;
  * `id` is the shorthand name of the token type as a `Symbol`;
  * `style` is the `Style` applied to the token.

"""
struct TokenIterator
    ctx::Context
    theme::Theme
end

Base.iterate(t::TokenIterator) = isempty(t.ctx.tokens) ? nothing : iterate(t::TokenIterator, 1)
Base.length(t::TokenIterator) = length(t.ctx.tokens)

function Base.iterate(t::TokenIterator, state)
    (state > length(t)) && return nothing

    token = t.ctx.tokens[state]
    result = (
        SubString(t.ctx.source, token.first, token.last),
        Tokens.__SHORTNAMES__[token.value.value],
        t.theme.styles[token.value.value],
    )

    return result, state + 1
end

# Code blocks.

render(io::IO, mime::MIME, ctx::Context, theme::Theme) =
    render(io, mime, TokenIterator(ctx, theme))

function render(io::IO, mime::MIME"text/html", tokens::TokenIterator)
    println(io, "<pre class='hljl'>")
    for (str, id, style) in tokens
        print(io, "<span class='hljl-")
        print(io, id, "'>")
        escape(io, mime, str)
        print(io, "</span>")
    end
    println(io, "\n</pre>")
end

const CONSECUTIVE_WHITESPACE = r"\s+"

function print_formatted(io::IO,mime::MIME"text/latex",str,id,style)
    id === :t || print(io, "(*@\\HLJL", id, "{")
    escape(io, mime, str; charescape=(id === :t))
    id === :t || print(io, "}@*)")
end

function render_nonwhitespace(io::IO,mime::MIME"text/latex",str,id,style)
    # Whitespace chars within an escapeinside are not correctly printed in a
    # lstlisting env. So in order to have the correct highlighting
    # and correct characters, that are recognized by listings, they need to be
    # added outside of the escapeinside.
    offset = 1
    for m in eachmatch(CONSECUTIVE_WHITESPACE,str)
        whitespace = m.match
        nonwhitespace = str[offset:prevind(str,m.offset)]
        offset = nextind(str,m.offset,length(whitespace))
        length(nonwhitespace) > 0 && print_formatted(io,mime,nonwhitespace,id,style)
        print(io,whitespace)
    end
    nonwhitespace = str[offset:end]
    length(nonwhitespace) > 0 && print_formatted(io,mime,str[offset:end],id,style)
end

function render(io::IO, mime::MIME"text/latex", tokens::TokenIterator)
    println(io, "\\begin{lstlisting}")
    for (str, id, style) in tokens
        render_nonwhitespace(io,mime,str,id,style)
    end
    println(io, "\n\\end{lstlisting}")
end

# Character escapes.

function escape(io::IO, ::MIME"text/html", str::AbstractString)
    for char in str
        char === '&'  ? print(io, "&amp;") :
        char === '<'  ? print(io, "&lt;") :
        char === '>'  ? print(io, "&gt;") :
        char === '"'  ? print(io, "&quot;") :
        char === '\'' ? print(io, "&#39;") :
            print(io, char)
    end
end

function escape(io::IO, ::MIME"text/latex", str::AbstractString; charescape=false)
    for char in str
        char === '`'   ? printe(io, charescape, "{\\textasciigrave}") :
        char === '\''  ? printe(io, charescape, "{\\textquotesingle}") :
        char === '$'   ? printe(io, charescape, "{\\\$}") :
        char === '%'   ? printe(io, charescape, "{\\%}") :
        char === '#'   ? printe(io, charescape, "{\\#}") :
        char === '&'   ? printe(io, charescape, "{\\&}") :
        char === '\\'  ? printe(io, charescape, "{\\textbackslash}") :
        char === '^'   ? printe(io, charescape, "{\\textasciicircum}") :
        char === '_'   ? printe(io, charescape, "{\\_}") :
        char === '{'   ? printe(io, charescape, "{\\{}") :
        char === '}'   ? printe(io, charescape, "{\\}}") :
        char === '~'   ? printe(io, charescape, "{\\textasciitilde}") :
        char === '"'   ? printe(io, charescape, "\"{}") :
            print(io, char)
    end
end

function printe(io::IO, charescape::Bool, s)
    charescape && print(io, "(*@{")
    print(io, s)
    charescape && print(io, "}@*)")
end

end # module
