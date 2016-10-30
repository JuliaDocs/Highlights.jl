# User Guide

So how do we highlight source code using the `Highlights` package?

Firstly we import the package -- assuming it has already been installed following the
guidelines found in [Installation](@ref).

```@example 1
using Highlights
```

This will make several names available to us for use:

  * `highlight` colourises and formats strings;
  * `stylesheet` prints out style definitions;
  * `lexers` returns a lexer that matches a textual name;
  * the `Themes` module provides a selection of theme definitions;
  * and the `Lexers` module provides a collection of lexer definitions.

Next we need a `String` to highlight. For this example we will be using the code sample from
[The Julia Language](http://julialang.org/) website.

```@example 1
source =
    """
    function mandel(z)
        c = z
        maxiter = 80
        for n = 1:maxiter
            if abs(z) > 2
                return n-1
            end
            z = z^2 + c
        end
        return maxiter
    end

    function randmatstat(t)
        n = 5
        v = zeros(t)
        w = zeros(t)
        for i = 1:t
            a = randn(n,n)
            b = randn(n,n)
            c = randn(n,n)
            d = randn(n,n)
            P = [a b c d]
            Q = [a b; c d]
            v[i] = trace((P.'*P)^4)
            w[i] = trace((Q.'*Q)^4)
        end
        std(v)/mean(v), std(w)/mean(w)
    end
    """
nothing # hide
```

To highlight `source` we pass it to `highlight` along with the output stream, the required
output format, the lexer, and, optionally, the theme.

```@example 1
open("source.html", "w") do stream
    highlight(stream, MIME("text/html"), source, Lexers.JuliaLexer)
end
```

This will print the highlighted version of `source` to `source.html` using the `JuliaLexer`
definition and the `DefaultTheme`. We can also output ``\LaTeX`` formatted text by using
`MIME("text/latex")` instead.

Note though that at this point we have not included any style information needed to
colourise and typeset the text that `highlight` has printed to the file. For that we need to
call `stylesheet` first as follows:

```@example 1
open("source.html", "w") do stream
    stylesheet(stream, MIME("text/html"))
    highlight(stream, MIME("text/html"), source, Lexers.JuliaLexer)
end
```

*The highlighted version of `source` is available from [here](source.html).*

`stylesheet` is passed most of the same information that `highlight` is aside from the
`source`.

!!! note

    The above example will not produce a *complete* HTML page. No `<html>`, `<head>`, or
    `<body>` are printed. This is left to the user to decide what approach would suit their
    usecase best.

    Also note that if you would like to print the stylesheet to a `.css` file rather than to
    the same `index.html` then you may use:

    ```@example 1
    open("theme.css", "w") do stream
        stylesheet(stream, MIME("text/css"))
    end
    ```

That's all there is to it. Have a look at the [Theme Guide](@ref) and [Lexer Guide](@ref) if
you would like to define your own themes and lexers. Please consider contributing any that
you write back to the package so that all users can benefit from them -- no lexer or theme
is too obscure to include in `Highlights`!

