module Format

import ..Highlights.Compiler: Context
import ..Highlights.Themes: RGB, Style, Theme
import ..Highlights.Tokens


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
    println(io, "\\usepackage[T1]{fontenc}")
    println(io, "\\usepackage{textcomp}")
    println(io, "\\usepackage{upquote}")
    println(io, "\\usepackage{listings}")
    println(io, "\\usepackage{xcolor}")
    print(io,
        """
        \\lstset{
            basicstyle=\\ttfamily\\footnotesize,
            upquote=true,
            breaklines=true,
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


# Code blocks.

function render(io::IO, mime::MIME"text/html", ctx::Context, theme::Theme)
    println(io, "<pre class='hljl'>")
    for token in ctx.tokens
        print(io, "<span class='hljl-")
        print(io, Tokens.__SHORTNAMES__[token.value.value], "'>")
        escape(io, mime, SubString(ctx.source, token.first, token.last))
        print(io, "</span>")
    end
    println(io, "\n</pre>")
end

function render(io::IO, mime::MIME"text/latex", ctx::Context, theme::Theme)
    println(io, "\\begin{lstlisting}")
    for token in ctx.tokens
        if Tokens.__TOKENS__[token.value.value] === :TEXT
            print(io, SubString(ctx.source, token.first, token.last))
        else
            print(io, "(*@\\HLJL", Tokens.__SHORTNAMES__[token.value.value], "{")
            escape(io, mime, SubString(ctx.source, token.first, token.last))
            print(io, "}@*)")
        end
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

function escape(io::IO, ::MIME"text/latex", str::AbstractString)
    for char in str
        char === '`'  ? print(io, "{\\textasciigrave}") :
        char === '\'' ? print(io, "{\\textquotesingle}") :
        char === '$'  ? print(io, "{\\\$}") :
        char === '%'  ? print(io, "{\\%}") :
        char === '#'  ? print(io, "{\\#}") :
        char === '&'  ? print(io, "{\\&}") :
        char === '\\' ? print(io, "{\\textbackslash}") :
        char === '^'  ? print(io, "{\\textasciicircum}") :
        char === '_'  ? print(io, "{\\_}") :
        char === '{'  ? print(io, "{\\{}") :
        char === '}'  ? print(io, "{\\}}") :
        char === '~'  ? print(io, "{\\textasciitilde}") :
            print(io, char)
    end
end

end # module
