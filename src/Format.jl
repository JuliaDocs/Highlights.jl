module Format

import ..Highlights.Compiler: Context
import ..Highlights.Themes: Theme, Style, has_fg, has_bg
import ..Highlights.Tokens


# Styles.

function render(io::IO, ::MIME"text/css", style::Style)
    has_fg(style)   && print(io, "color: #", style.fg, "; ")
    has_bg(style)   && print(io, "background-color: #", style.bg, "; ")
    style.bold      && print(io, "font-weight: bold; ")
    style.italic    && print(io, "font-style: italic; ")
    style.underline && print(io, "text-decoration: underline; ")
    return nothing
end

function render(io::IO, ::MIME"text/latex", style::Style)
    print(io, "[1]{")
    has_fg(style)   && print(io, "\\textcolor[HTML]{", style.fg, "}{")
    has_bg(style)   && print(io, "\\colorbox[HTML]{", style.bg, "}{")
    style.bold      && print(io, "\\textbf{")
    style.italic    && print(io, "\\textit{")
    style.underline && print(io, "\\underline{")
    print(io, "#1")
    style.underline && print(io, "}")
    style.italic    && print(io, "}")
    style.bold      && print(io, "}")
    has_bg(style)   && print(io, "}")
    has_fg(style)   && print(io, "}")
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
        print(io, "pre.hljl > span.hljl-", Tokens.__TOKENS__[nth], " { ")
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
        print(io, "\\newcommand{\\HLJL", replace(string(Tokens.__TOKENS__[nth]), "_", ""), "}")
        render(io, mime, style)
        println(io)
    end
end


# Code blocks.

function render(io::IO, mime::MIME"text/html", ctx::Context, theme::Theme)
    println(io, "<pre class='hljl'>")
    for token in ctx.tokens
        print(io, "<span class='hljl-")
        print(io, Tokens.__TOKENS__[token.value.value], "'>")
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
            for (nth, line) in enumerate(split(SubString(ctx.source, token.first, token.last), '\n'))
                nth > 1 && println(io)
                local name = replace(string(Tokens.__TOKENS__[token.value.value]), "_", "")
                print(io, "(*@\\HLJL", name, "{")
                escape(io, mime, line)
                print(io, "}@*)")
            end
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
