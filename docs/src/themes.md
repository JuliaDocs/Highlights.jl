# Themes

Highlights.jl includes over 360 color themes from the [Gogh](https://gogh-co.github.io/Gogh/) project.

## Listing Themes

```julia
using Highlights

themes = Highlights.available_themes()
println(length(themes))
```

## Popular Themes

Some commonly used themes include:

- **Dracula** - Dark theme with purple accents
- **Nord** - Arctic, north-bluish color palette
- **Monokai Dark** - Classic dark theme
- **Gruvbox Dark** - Retro groove colors
- **One Dark** - Atom-inspired dark theme
- **Solarized Dark** - Precision colors for dark backgrounds
- **Tokyo Night** - Dark theme inspired by Tokyo lights
- **Catppuccin Mocha** - Soothing pastel theme

## Theme Selection

Themes are specified by exact name (case-sensitive):

```julia
highlight(code, :julia, "Dracula")
highlight(code, :julia, "Nord")
```

## Fuzzy Matching

If you mistype a theme name, Highlights.jl suggests similar themes based on edit distance:

```julia
highlight(code, :julia, "darcula")
# ERROR: Theme 'darcula' not found. Similar themes:
#   - Dracula
#   - ...
```

```julia
highlight(code, :julia, "monokai")
# ERROR: Theme 'monokai' not found. Similar themes:
#   - Monokai Dark
#   - Monokai Pro
#   - ...
```

## Theme Colors

Each theme provides:
- 16 ANSI colors (used for syntax highlighting)
- Background color
- Foreground color

The syntax highlighting maps TreeSitter captures to these colors based on token type (keywords, strings, comments, etc.).

## Custom Themes

Create custom themes by deriving from existing themes:

```julia
# Override specific colors (2 = keywords)
custom = Theme("Dracula", colors = Dict(2 => "#ff0000"))
highlight(code, :julia, custom)

# Change background
Theme("Nord", background = "#1a1a1a")

# Give it a new name
Theme("Dracula", name = "MyDracula", colors = Dict(2 => "#ff0000"))

# Chain derivations
base = Theme("Dracula", background = "#1a1a1a")
custom = Theme(base, colors = Dict(3 => "#00ff00"))
```

### Per-Capture Styling

Themes can attach text styling — `:bold`, `:italic`, `:underline` — to
tree-sitter captures via the `styles` keyword. A bare Symbol or a
Vector of Symbols is accepted:

```julia
Theme("Dracula", styles = Dict(
    "comment"  => :italic,
    "keyword"  => :bold,
    "function" => [:bold, :italic],
    "type"     => :underline,
))
```

Lookup walks the capture hierarchy, so setting `"keyword"` covers
`"keyword.return"`, `"keyword.function"`, etc.

Gogh themes ship without styling — set it explicitly when you derive
your own. Styles work in every output format: ANSI, HTML (inline and
class-based), LaTeX, and Typst.

#### Removing Styling

Styles use override semantics during derivation (matching `colors`).
To remove a style inherited from a base, set the capture to an empty
Vector:

```julia
italic_comments = Theme("Dracula", styles = Dict("comment" => :italic))
no_style        = Theme(italic_comments, styles = Dict("comment" => Symbol[]))
```

#### LaTeX and Underline

If any capture uses `:underline`, the LaTeX output uses `\\uline` from
the `ulem` package. The generated stylesheet
([`Highlights.stylesheet`](@ref) for `MIME("text/latex")`) includes
`\\usepackage[normalem]{ulem}` automatically. For inline LaTeX output,
add the package to your document preamble.

### Loading from JSON Files

Load themes from external JSON files (Gogh-compatible format):

```julia
highlight(code, :julia, "/path/to/theme.json")

# Or derive from a file
custom = Theme("/path/to/theme.json", colors = Dict(2 => "#ff0000"))
```

File-based themes are not cached, allowing live editing.

### JSON Format

```json
{
  "name": "MyTheme",
  "background": "#282A36",
  "foreground": "#F8F8F2",
  "color_01": "#262626",
  "color_02": "#E64747",
  "color_03": "#42E66C",
  "color_04": "#E4F34A",
  "color_05": "#9B6BDF",
  "color_06": "#E356A7",
  "color_07": "#75D7EC",
  "color_08": "#F8F8F2",
  "color_09": "#7A7A7A",
  "color_10": "#FF5555",
  "color_11": "#50FA7B",
  "color_12": "#F1FA8C",
  "color_13": "#BD93F9",
  "color_14": "#FF79C6",
  "color_15": "#8BE9FD",
  "color_16": "#F9F9FB"
}
```

Required: `name`. Optional: `background`, `foreground`, `color_01`-`color_16`.

JSON theme files carry colors only — to attach per-capture styling,
load the file and derive: `Theme("/path/to/theme.json", styles = …)`.

### Color Indices

The 16 colors map to syntax elements:

| Index | Default Use |
|-------|-------------|
| 1 | Comments |
| 2 | Keywords |
| 3 | Strings |
| 4 | Types |
| 5 | Functions |
| 6 | Variables |
| 7 | Constants |
| 8 | Operators |
| 9-16 | Bright variants |
