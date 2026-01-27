# User Guide

## Basic Usage

The main function is `highlight`, which takes source code, a language, and a theme:

```julia
using Highlights

code = """
function factorial(n)
    n <= 1 ? 1 : n * factorial(n - 1)
end
"""

# Returns a highlighted string
result = highlight(code, :julia, "Dracula")
println(result)
```

## Output Formats

Output format is specified as the first argument (MIME type string or `MIME` object):

| MIME Type | Description |
|-----------|-------------|
| `"text/ansi"` | Terminal with 24-bit true color (default when omitted) |
| `"text/html"` | `<pre>` with inline `<span style="color: #hex">` |
| `"text/latex"` | lstlisting with `\textcolor` |
| `"text/typst"` | Typst markup with `#text(fill: rgb(...))` |
| `"text/plain"` | Debug format showing `[capture:text]` |

```julia
# Default ANSI output
ansi = highlight(code, :julia, "Dracula")

# HTML output
html = highlight("text/html", code, :julia, "Nord")

# LaTeX output
latex = highlight("text/latex", code, :julia, "Monokai Dark")

# Typst output
typst = highlight("text/typst", code, :julia, "Catppuccin Mocha")

# Debug output showing token types
debug = highlight("text/plain", code, :julia, "Dracula")
```

## Writing to IO

You can write directly to an IO stream by passing `io` and `mime` as the first two arguments:

```julia
open("output.html", "w") do io
    highlight(io, "text/html", code, :julia, "Dracula")
end
```

## Language Specification

Languages can be specified in several ways:

```julia
# As a Symbol (recommended)
highlight(code, :julia, "Dracula")

# As a String
highlight(code, "julia", "Dracula")

# As a JLL module (for advanced use)
using tree_sitter_julia_jll
highlight(code, tree_sitter_julia_jll, "Dracula")
```

### Case Insensitivity

Language names are case-insensitive:

```julia
highlight(code, :Julia, "Dracula")   # works
highlight(code, "JULIA", "Dracula")  # works
```

### Language Aliases

Common shorthand aliases are supported:

| Alias | Language |
|-------|----------|
| `js` | `javascript` |
| `ts` | `typescript` |
| `py` | `python` |
| `rb` | `ruby` |
| `yml` | `yaml` |
| `rs` | `rust` |
| `cs` | `c_sharp` |
| `c++`, `cxx` | `cpp` |
| `sh`, `shell`, `zsh` | `bash` |
| `jl` | `julia` |
| `ml` | `ocaml` |
| `f90`, `f95` | `fortran` |

```julia
highlight(js_code, :js, "Nord")  # Uses tree_sitter_javascript_jll
```

## Theme Selection

Themes are specified by name (case-sensitive):

```julia
highlight(code, :julia, "Dracula")
highlight(code, :julia, "Nord")
highlight(code, :julia, "Monokai Dark")
```

### Listing Available Themes

```julia
themes = Highlights.available_themes()  # Returns sorted Vector{String}
```

### Theme Suggestions

If you mistype a theme name, similar themes are suggested:

```julia
highlight(code, :julia, "dracual")
# ERROR: Theme 'dracual' not found. Similar themes:
#   - Dracula
#   - ...
```

## Error Handling

### Unknown Language

If a language grammar isn't installed:

```julia
highlight(code, :python, "Dracula")
# ERROR: Language 'python' requires package 'tree_sitter_python_jll'.
#        Install with: Pkg.add("tree_sitter_python_jll")
```

If a language doesn't exist, similar languages are suggested:

```julia
highlight(code, :pythn, "Dracula")
# ERROR: Language 'pythn' not found. Similar languages (install via Pkg.add):
#   - python (tree_sitter_python_jll)
#   - ...
```

### Unknown Theme

Similar themes are suggested on typos (see above).

## Custom Token Transforms

The `transform` keyword lets you wrap tokens with custom markup:

```julia
function link_docs(io::IO, ::MIME"text/html", token, entering::Bool, source, language)
    if token.capture == "function.call" && entering
        print(io, "<a href=\"/docs/$(token.text)\">")
    elseif token.capture == "function.call" && !entering
        print(io, "</a>")
    end
end
link_docs(::IO, ::MIME, args...) = nothing  # Fallback for other MIMEs

html = highlight("text/html", code, :julia, "Dracula"; transform=link_docs)
```

The transform function receives:
- `io`: Output stream
- `mime`: Output MIME type
- `token`: Token object with fields `.text`, `.capture`, `.byte_range`, `.node`
- `entering`: `true` before token, `false` after
- `source`: Full source code
- `language`: Language symbol (e.g., `:julia`)

## Preprocessors

Preprocessors handle mixed-language content by splitting source into segments before highlighting.

### Segment Types

```julia
# Code to be syntax-highlighted
CodeSegment(text::String, language::Symbol)

# Text with a single theme color (no highlighting)
StyledSegment(text::String, color::Int)  # color: 0=foreground, 1-16=theme colors
```

### Built-in: Julia REPL

`jlcon_preprocess` handles Julia REPL sessions:

```julia
using Highlights: jlcon_preprocess

repl_session = """
julia> x = 1 + 2
3

julia> println("hello")
hello
"""

# Prompts get color 11, output gets foreground, code gets syntax highlighted
html = highlight("text/html", repl_session, :julia, "Dracula"; preprocess=jlcon_preprocess)
```

### Pseudo-Language Auto-Detection

The pseudo-languages `:jlcon`, `:pycon`, and `:rcon` auto-detect their preprocessors:

```julia
# Equivalent to using preprocess=jlcon_preprocess
highlight("text/html", repl_session, :jlcon, "Dracula")
```

Built-in pseudo-languages:
- `:jlcon` - Julia REPL (prompts: `julia>`, `help?>`, `shell>`, `pkg>`)
- `:pycon` - Python REPL (prompts: `>>>`, `...`)
- `:rcon` - R REPL (prompts: `>`, `+`)

### Custom Preprocessors

Create your own by returning a `Vector{Segment}`:

```julia
function my_preprocessor(source::AbstractString)
    segments = Segment[]
    # Parse source and create CodeSegment/StyledSegment entries
    push!(segments, StyledSegment("# Header\n", 3))
    push!(segments, CodeSegment("println(\"hi\")", :julia))
    return segments
end

highlight("text/html", source, :julia, "Nord"; preprocess=my_preprocessor)
```

## Stylesheets

Generate external stylesheets for class-based highlighting instead of inline styles.

### Generating Stylesheets

```julia
using Highlights: stylesheet

# Raw CSS
css = stylesheet("Dracula")

# CSS wrapped in <style> tags
html_style = stylesheet("text/html", "Nord")

# LaTeX color definitions and commands
latex_style = stylesheet("text/latex", "Monokai Dark")
```

### Class-Based Output

Use `stylesheet=true` in `highlight()` to emit class-based markup:

```julia
# HTML with classes instead of inline styles
code_html = highlight("text/html", code, :julia, "Dracula"; stylesheet=true)
# → <pre class="hl"><span class="hl-c1">function</span>...</pre>

# Combine with stylesheet for complete HTML
full_html = stylesheet("text/html", "Dracula") * code_html
```

### Custom Class Prefix

```julia
css = stylesheet("Dracula"; classprefix="syntax")
# → pre.syntax { ... }
# → .syntax-c1 { ... }

code = highlight("text/html", src, :julia, "Dracula"; stylesheet=true, classprefix="syntax")
```

## Notebook Display

The `Highlight` type wraps highlighted code for automatic display in Pluto, Jupyter, and other rich environments:

```julia
using Highlights

code = Highlight("println(1)", :julia, "Dracula")
# Displays as: ANSI in terminal, HTML in notebooks
```

Constructor arguments match `highlight()`. The `Theme` type also supports rich display:

```julia
theme = Highlights.load_theme("Dracula")
# Displays color swatches in notebooks, ANSI preview in terminal
```
