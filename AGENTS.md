# AGENTS.md

This file provides guidance to AI coding assistants working with this repository.

## Build & Test Commands

```bash
# Run all tests
julia --project -e 'using Pkg; Pkg.test()'

# Update Gogh themes to latest release
julia --project scripts/update_gogh.jl
```

## Architecture

Highlights.jl provides syntax highlighting using TreeSitter.jl for parsing. Core flow:

```
Source → TreeSitter Parser → Query Captures → Theme Colors → Output Format
```

### Key Modules

- **Highlights.jl** - Main module. Exports `highlight(source, language, theme_name; format=:ansi)`
- **highlight.jl** - Token extraction, deduplication, capture→color mapping
- **languages.jl** - Language grammar loading from JLL packages
- **themes.jl** - Load Gogh themes from artifact via `Artifacts.artifact"Gogh"`
- **preprocessors.jl** - REPL session preprocessing (jlcon, pycon, rcon)
- **stylesheet.jl** - External stylesheet generation (CSS, LaTeX)
- **ansi.jl** - ANSI escape code utilities
- **formats/** - Output formatters (ansi.jl, html.jl, latex.jl, typst.jl, plain.jl)

### Usage

```julia
using Highlights

code = "function hello() println(\"Hi\") end"

# Language as Symbol (auto-loads tree_sitter_julia_jll)
println(highlight(code, :julia, "Dracula"))

# Language as String
html = highlight(code, "julia", "Nord"; format=:html)
```

Language JLL packages must be installed but are auto-loaded when using Symbol/String syntax.

### Output Formats

- `:ansi` - Terminal with 24-bit true color
- `:html` - `<pre>` with inline `<span style="color: #hex">`
- `:latex` - lstlisting with `\textcolor`
- `:typst` - Typst markup with `#text(fill: ...)`
- `:plain` - Debug format: `[capture:text]`

### Themes

362 themes from Gogh project, accessed via Julia Artifacts. Update with `scripts/update_gogh.jl`.
