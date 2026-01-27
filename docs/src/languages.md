# Languages

Highlights.jl uses TreeSitter grammar packages for parsing. These are distributed as JLL packages.

## Installing Language Grammars

Install the grammar for each language you want to highlight:

```julia
using Pkg
Pkg.add("tree_sitter_julia_jll")
Pkg.add("tree_sitter_python_jll")
Pkg.add("tree_sitter_javascript_jll")
```

## Discovering Available Languages

List all grammar packages available in the Julia registry:

```julia
using Highlights

languages = Highlights.available_languages()
# ["bash", "c", "cpp", "css", "go", "html", "java", "javascript", "json", "julia", ...]
```

Each name corresponds to a `tree_sitter_<name>_jll` package.

## Language Aliases

Common shorthand aliases are supported:

| Alias | Resolves To | Package |
|-------|-------------|---------|
| `js` | `javascript` | `tree_sitter_javascript_jll` |
| `ts` | `typescript` | `tree_sitter_typescript_jll` |
| `py` | `python` | `tree_sitter_python_jll` |
| `rb` | `ruby` | `tree_sitter_ruby_jll` |
| `yml` | `yaml` | `tree_sitter_yaml_jll` |
| `rs` | `rust` | `tree_sitter_rust_jll` |
| `cs` | `c_sharp` | `tree_sitter_c_sharp_jll` |

```julia
# These are equivalent:
highlight(code, :js, "Dracula")
highlight(code, :javascript, "Dracula")
```

## Case Insensitivity

Language names are case-insensitive:

```julia
highlight(code, :Julia, "Dracula")   # works
highlight(code, "PYTHON", "Dracula") # works
```

## Fuzzy Matching

If you misspell a language, similar languages are suggested:

```julia
highlight(code, :jula, "Dracula")
# ERROR: Language 'jula' not found. Similar languages (install via Pkg.add):
#   - julia (tree_sitter_julia_jll)
#   - lua (tree_sitter_lua_jll)
#   - java (tree_sitter_java_jll)
```

## Grammar Not Installed

If you try to use a language that exists but isn't installed:

```julia
highlight(code, :rust, "Dracula")
# ERROR: Language 'rust' requires package 'tree_sitter_rust_jll'.
#        Install with: Pkg.add("tree_sitter_rust_jll")
```

## Using JLL Modules Directly

For advanced use, you can pass the JLL module directly:

```julia
using tree_sitter_julia_jll
highlight(code, tree_sitter_julia_jll, "Dracula")
```

This skips the language resolution step.
