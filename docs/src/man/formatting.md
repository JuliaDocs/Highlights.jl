# Formatting

`Highlights` provides two output formats for highlighted source code, namely `text/html` and
`text/latex` -- both of which have been shown in previous sections of this manual. In this
section we'll be describing how to go about extending `Highlights` formatting to support
user-defined formats.

To begin we will need to import the `Format` module from `Highlights`.

```julia
using Highlights: Format, highlight
```

Now we need to decide on a format the we'd like to add. We'll be adding an ANSI
formatter that can be used to display highlighted source code in the terminal.
For that we'll need to install the `Crayons` package.

```julia
Pkg.add("Crayons")
using Crayons
```

Next we'll define a `Format.render` method that will be used to highlight tokenised source
code using a user-provided theme.

```julia
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
```

!!! note

    The `io` argument to `render` needs to be a subtype of `IO`. To allow for more exotic
    "buffer"-like objects, such as `push!`ing rendered tokens to a vector one can use a
    custom wrapper type such as

    ```julia
    immutable BufferWrapper <: IO
        buffer::IOBuffer
        data::Vector{RGBA{Float32}}
    end
    ```

    where the source needs to be written to a buffer while the colour data has to be pushed
    to a separate vector of colours.

To view highlighted source code in the terminal we can then just call

```
julia> highlight(stdout, MIME("text/ansi"), source, Lexers.JuliaLexer)
```
