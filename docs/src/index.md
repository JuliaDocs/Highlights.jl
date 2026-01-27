# Highlights.jl

*Syntax highlighting for Julia using TreeSitter.*

## Overview

Highlights.jl provides syntax highlighting using [TreeSitter](https://tree-sitter.github.io/tree-sitter/) for parsing and themes from the [Gogh](https://gogh-co.github.io/Gogh/) project.

## Installation

```julia
using Pkg
Pkg.add("Highlights")
```

You'll also need to install grammar packages for the languages you want to highlight:

```julia
Pkg.add("tree_sitter_julia_jll")
```

## Quick Start

```julia
using Highlights

code = """
function greet(name)
    println("Hello, \$name!")
end
"""

# Terminal output (ANSI colors)
println(highlight(code, :julia, "Dracula"))

# HTML output
html = highlight("text/html", code, :julia, "Nord")
```

## Features

- **Over 360 color themes** from the Gogh project
- **Multiple output formats**: ANSI (terminal), HTML, LaTeX, Typst, plain text
- **Language aliases**: `js`, `ts`, `py`, `rb`, `yml`, `rs`, `cs`
- **Fuzzy matching**: Suggests similar themes/languages on typos

## Contents

```@contents
Pages = ["guide.md", "themes.md", "languages.md", "demos.md", "api.md"]
Depth = 1
```
