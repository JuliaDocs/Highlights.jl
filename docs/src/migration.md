# Migrating from 0.5 to 0.6

`Highlights@0.6` swapped the regex-lexer architecture for
[TreeSitter](https://tree-sitter.github.io/tree-sitter/) parsing, and
the 0.5 `@theme` macro for the 16-color
[Gogh](https://gogh-co.github.io/Gogh/) palette model. The 0.5 macros
(`@theme`, `@lexer`, `S"..."`), the `Tokens.*` constants, and the
built-in `Lexers.*` and `Themes.*` types are gone. Custom themes have
to be rebuilt against the 16-color palette.

## API at a glance

| 0.5 | 0.6 |
| --- | --- |
| `@theme MyTheme Dict(:tokens => …)` | [`Theme`](@ref) constructor or Gogh-format JSON file |
| `Themes.MonokaiTheme` (etc.) | `"Monokai Dark"` (Gogh name; see [`Highlights.available_themes`](@ref)) |
| `Lexers.JuliaLexer` (etc.) | `:julia` (Symbol or String); `tree_sitter_julia_jll` is auto-loaded |
| `Tokens.KEYWORD`, `Tokens.NAME_FUNCTION`, … | tree-sitter capture names: `"keyword"`, `"function"`, … |
| `S"fg: 7a93f5; bold; italic"` | color via `Theme.colors[i]`; styles via `Theme(...; styles = Dict("keyword" => [:bold, :italic]))` |
| `highlight(io, MIME("text/html"), src, Lexer, Theme)` | `highlight(io, "text/html", src, :julia, "Dracula")` |
| `Format.render(io, mime, tokens)` override | `transform = callback` keyword |
| `Style.fg.r/g/b/active`, `bold`, `italic`, `underline` | `Theme.colors[i]::String` (hex); `Theme.styles[capture]::Vector{Symbol}` (`:bold`, `:italic`, `:underline`) |
| `stylesheet(io, MIME("text/html"), Theme)` | `stylesheet(io, "text/html", "Dracula")` |

## Theme migration

### The 16-color model

A [`Theme`](@ref) holds a `Dict{Int,String}` of 16 hex colors plus a
`background` and `foreground`. `Highlights.default_capture_colors`
maps tree-sitter capture names to those indices. The defaults:

| Index | Captures (default) |
| ----- | ------------------ |
| 1 | `comment` |
| 2 | `keyword`, `keyword.*`, `conditional`, `repeat`, `include` |
| 3 | `string`, `character` |
| 4 | `number`, `boolean`, `constant` |
| 5 | `function`, `function.call`, `method`, `method.call`, `constructor` |
| 6 | `function.macro`, `string.escape`, `macro` |
| 7 | `type`, `type.definition`, `module`, `namespace` |
| 8 | `variable`, `variable.parameter`, `property`, `operator`, `punctuation`, `punctuation.*` |
| 9 | (unused) |
| 10 | `error` |
| 11 | `string.special` |
| 12 | `constant.builtin` |
| 13 | `function.builtin` |
| 14 | `variable.builtin` |
| 15 | `type.builtin` |
| 16 | (unused) |

Indices 9–16 are conventionally the "bright" ANSI variants.

### From 0.5 token constants to 0.6 captures

| 0.5 token | 0.6 capture | Default index |
| --- | --- | --- |
| `KEYWORD` | `keyword` | 2 |
| `KEYWORD_CONSTANT` | `constant.builtin` | 12 |
| `NAME_FUNCTION` | `function`, `function.call` | 5 |
| `NAME_BUILTIN` | `function.builtin` | 13 |
| `NAME_CLASS`, `NAME_NAMESPACE` | `type`, `module`, `namespace` | 7 |
| `NAME_OTHER`, `NAME_VARIABLE` | `variable` | 8 |
| `STRING`, `STRING_DOC` | `string` | 3 |
| `STRING_ESCAPE` | `string.escape` | 6 |
| `NUMBER`, `NUMBER_FLOAT`, … | `number` | 4 |
| `OPERATOR`, `PUNCTUATION` | `operator`, `punctuation` | 8 |
| `COMMENT`, `COMMENT_*` | `comment` | 1 |
| `ERROR` | `error` | 10 |
| `TEXT` | (uncaptured; uses `foreground`) | — |

The 0.5 model had ~76 distinct token types; tree-sitter exposes a
smaller, hierarchical set, so several 0.5 tokens collapse onto one
0.6 index. `STRING` and `STRING_DOC` both land on `"string"`. If you
need finer-grained color, use a `transform` callback (see
[Custom Token Transforms](@ref)) and dispatch on `token.capture` or
on the AST `token.node`.

`bold`, `italic`, and `underline` from the 0.5 `S"…"` syntax map onto
the per-capture `styles` field on a 0.6 `Theme`. A bare Symbol or a
Vector of Symbols both work, and lookup walks the capture hierarchy
(setting `"keyword"` covers `"keyword.return"`):

```julia
Theme("Dracula"; styles = Dict(
    "comment"  => :italic,
    "keyword"  => :bold,
    "function" => [:bold, :italic],
    "type"     => :underline,
))
```

Valid style symbols are `:bold`, `:italic`, and `:underline`. Gogh
themes ship without any styling — you opt in per-capture when you
derive your own.

For the full set of ways to build a `Theme` (deriving from Gogh,
loading from JSON, constructing directly), see [Themes](@ref).

## Lexer migration

### Built-in lexers

Built-in 0.5 lexers are gone. Install the matching tree-sitter grammar
JLL and pass a Symbol or String:

| 0.5 | 0.6 |
| --- | --- |
| `Lexers.JuliaLexer` | `:julia` (`tree_sitter_julia_jll`) |
| `Lexers.JuliaConsoleLexer` | `:jlcon` (handled by `jlcon_preprocess`; needs `tree_sitter_julia_jll` and `tree_sitter_bash_jll` for shell mode) |
| `Lexers.FortranLexer` | `:fortran`, alias `f90`/`f95` |
| `Lexers.MatlabLexer` | `:matlab` |
| `Lexers.RLexer` | `:r` |
| `Lexers.TOMLLexer` | `:toml` |

[`Highlights.available_languages`](@ref) lists every JLL it knows
about. JLLs load on first use; if one isn't installed, the error
message tells you exactly what to `Pkg.add`.

### Custom `@lexer` definitions

There is no replacement. The 0.6 architecture is built on tree-sitter
grammars compiled into JLL packages, so a custom 0.5 regex `@lexer`
cannot be ported in place. Options:

- Find an existing tree-sitter grammar for your language and use the
  matching `tree_sitter_<lang>_jll`.
- Write a tree-sitter grammar (see the
  [tree-sitter docs](https://tree-sitter.github.io/tree-sitter/creating-parsers))
  and package it as a JLL.
- Stay on `Highlights@0.5`.

## Worked example: porting a custom theme

`Highlights@0.5` shipped `render` methods only for `MIME"text/html"`,
`MIME"text/css"`, and `MIME"text/latex"`. Anyone who wanted terminal
output had to add their own `Format.render(io, ::MIME"text/ansi",
tokens)` method that walked the token stream and emitted ANSI escape
codes by hand. A typical 0.5 setup paired a custom theme with that
override:

```julia
# 0.5
using Highlights: Highlights
using Highlights.Format
using Highlights.Tokens, Highlights.Themes

abstract type CodeTheme <: AbstractTheme end

@theme CodeTheme Dict(
    :style => S"",
    :tokens => Dict(
        TEXT          => S"fg: dedede;",
        NAME_FUNCTION => S"fg: e8d472;",
        NAME_OTHER    => S"fg: e8d472;",
        KEYWORD       => S"fg: 7a93f5;",
        OPERATOR      => S"fg: de6d59;",
        PUNCTUATION   => S"fg: e38864",
        STRING        => S"fg: 50ad5f",
        COMMENT       => S"fg: 287a36; italic",
        STRING_DOC    => S"fg: 50ad5f",
        NUMBER        => S"fg: 90CAF9",
    ),
)

function Format.render(io::IO, ::MIME"text/ansi", tokens::Format.TokenIterator)
    for (str, id, style) in tokens
        # build escape codes from style.fg / style.bg / style.bold / …
        # and print(io, "\e[…m$str\e[0m")
    end
end

txt = sprint(Highlights.highlight, MIME("text/ansi"), code,
             Lexers.JuliaLexer, CodeTheme; context = stdout)
```

In 0.6 the entire `Format.render` override goes away: `MIME"text/ansi"`
is a built-in format, so [`highlight`](@ref) returns 24-bit-color ANSI
directly. Only the theme needs porting:

```julia
# 0.6
using Highlights

const CODE_THEME = Theme("Dracula";
    name       = "CodeTheme",
    foreground = "#dedede",
    colors = Dict(
        1 => "#287a36",  # comment
        2 => "#7a93f5",  # keyword
        3 => "#50ad5f",  # string  (covers STRING and STRING_DOC)
        4 => "#90CAF9",  # number / constant
        5 => "#e8d472",  # function (NAME_FUNCTION)
        6 => "#e8d472",  # macro / string.escape (also NAME_OTHER overflow)
        8 => "#de6d59",  # operator / punctuation / variable
    ),
    styles = Dict(
        "comment" => :italic,  # 0.5 had `italic` on COMMENT
    ),
)

txt = highlight(MIME("text/ansi"), code, :julia, CODE_THEME)
```

If the 0.5 `Format.render` was emitting something *other* than ANSI
(e.g. a downstream markup language that another library re-styles),
keep that wrapping with a `transform` callback instead — see
[Custom Token Transforms](@ref).

Things to watch when porting:

- 0.5 styling (`bold`, `italic`, `underline` on `S"…"`) maps onto the
  `styles` keyword on the `Theme` constructor — see the example above
  and [Themes](@ref).
- `OPERATOR` and `PUNCTUATION` both land on index 8. The 0.5 theme
  gave them different colors; in 0.6 you pick one. If both matter,
  branch on `token.capture` from a `transform` callback.
- `NAME_OTHER` is approximate. Tree-sitter's `variable` capture also
  covers operators and punctuation by default, so the example parks
  identifier color on index 6 (alongside `function.macro` and
  `string.escape`) to keep plain names yellow without recoloring
  operators. Adjust to taste.
- The 0.5 `Format.render` override is no longer needed for ANSI
  output. If your override was doing more than emitting escape codes
  (linking, custom markup, etc.), port that logic to a `transform`
  callback.

## Verifying a port

- `println(highlight(sample, :julia, MyTheme))` in a true-color terminal.
- `highlight("text/plain", sample, :julia, MyTheme)` prints
  `[capture:text]` debug output so you can confirm captures land where
  you expect.
- `display(Highlight(sample, :julia, MyTheme))` renders rich output in
  Pluto/Jupyter for visual comparison against the 0.5 result.
