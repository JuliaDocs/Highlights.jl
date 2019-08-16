"""
Module for interactive testing of highlighters in the REPL. Crayons is not a dependency and
must be installed separately for this module to work.
"""
module Console

using Crayons, Highlights

function Format.render(io::IO, ::MIME"text/ansi", tokens::Format.TokenIterator)
    for (str, id, style) in tokens
        fg = style.fg.active ? map(Int, (style.fg.r, style.fg.g, style.fg.b)) : :nothing
        bg = style.bg.active ? map(Int, (style.bg.r, style.bg.g, style.bg.b)) : :nothing
        crayon = Crayon(
            foreground = fg,
            background = bg,
            bold       = style.bold,
            italics    = style.italic,
            underline  = style.underline,
        )
        print(io, crayon, str, inv(crayon))
    end
end

test(text, lexer) = Highlights.highlight(stdout, MIME("text/ansi"), text, lexer)

end
