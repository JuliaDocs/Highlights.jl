# Theme Guide

This page outlines how to go about adding new theme definitions to `Highlights`.

## Required Imports

To get started adding a new theme definition you will need to import the following two
submodules of `Highlights`.

```@example 1
using Highlights.Tokens, Highlights.Themes
```

`Tokens` provides a collection of *tokens* that are used to label different parts of the
tokenised source code -- such as `TEXT` or `STRING`. `Themes` provides the `AbstractTheme`
type and `@theme` macro used to define new themes.

## The `AbstractTheme` Type

`AbstractTheme` is the super type of all theme definitions in `Highlights`. A theme is just
an `abstract` type that is a subtype of `AbstractTheme`. For this example we will define a
new theme called, very imaginatively, `CustomTheme`:

```@example 1
abstract type CustomTheme <: AbstractTheme end
```

That's all there is to the type itself. Next we'll define what colours should be used for
each token [^1] when we highlight source code using our new theme.

## The `@theme` Macro

Now we'll use the `@theme` macro to tell `Highlights` what colours we want different parts
of our source code to be highlighted in. We do this by calling the `@theme` macro to define
a set of rules that must be applied to each token.

```@example 1
@theme CustomTheme Dict(
    :style => S"bg: f7f3ee; fg: 605b53",
    :tokens => Dict(
        TEXT    => S"",
        KEYWORD => S"fg: 614c60; bold",
        STRING  => S"fg: a1789f",
        COMMENT => S"fg: ad9c84; italic",
    ),
)
nothing # hide
```

There's a couple of things going on up there, so let's split it into sections:

  * The first line calls the `@theme` macro with two arguments. The first being the name of
    the type, and the second a `Dict` literal which will contain the style rules.

  * Line two, i.e. `:style => ...`, defines the default style for code blocks styled with
    this theme. The `S"` string macro is used to write the nessecary style information. It
    is a `;`-separated string where each part of the string is one of

      * `bg: <html-color-code>` -- the background colour as an HTML 3 or 6 digit hex code;

      * `fg: <html-color-code>` -- as above, but for the foreground colour;

      * `bold` -- boldface text;

      * `italic` -- emphasised text;

      * `underline` -- underlined text.

  * Line three, the `:tokens` line, defines the `Dict` of token-to-style rules;

  * Line four defines what colour default text should be, this must **always** be included
    for the theme to work. We set it to `S""`, which is "no styling".

  * The rest of the lines just set out rules for other tokens that we would like to
    emphasise using different colours and font styles.

## Using the theme

Now that we've written a new theme we might as well try it out. We'll use the new theme
to highlight itself:

```@setup 1
using Highlights
source =
"""
# Required imports...
using Highlights, Highlights.Tokens, Highlights.Themes

# ... the theme type...
abstract CustomTheme <: AbstractTheme

# ... and finally the theme definition.
@theme CustomTheme Dict(
    :style => S"bg: f7f3ee; fg: 605b53",
    :tokens => Dict(
        TEXT    => S"",
        KEYWORD => S"fg: 614c60; bold",
        STRING  => S"fg: a1789f",
        COMMENT => S"fg: ad9c84; italic",
    ),
)

# Let's also print it to a file to we can have a look.
open("custom-theme.html", "w") do stream
    stylesheet(stream, MIME("text/html"), CustomTheme)
    highlight(stream, MIME("text/html"), source, Lexers.JuliaLexer, CustomTheme)
end
"""
```

```@example 1
open("custom-theme.html", "w") do stream
    stylesheet(stream, MIME("text/html"), CustomTheme)
    highlight(stream, MIME("text/html"), source, Lexers.JuliaLexer, CustomTheme)
end
```

*The highlighted code can be found [here](custom-theme.html).*

[^1]:

    "Tokens" refer to the substrings of the input string with an identified "meaning". For
    example `:string`, `:number`, `:text`, or `:keyword`.
