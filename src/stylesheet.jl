# Stylesheet generation for class-based highlighting

"""
    stylesheet(theme_name::String; classprefix="hl") -> String
    stylesheet(mime, theme_name::String; classprefix="hl") -> String
    stylesheet(io::IO, mime, theme_name::String; classprefix="hl")

Generate a stylesheet for class-based syntax highlighting.

# Arguments
- `classprefix`: Prefix for CSS classes/LaTeX commands (default "hl")

# Supported MIME types
- `MIME"text/css"` - Raw CSS rules
- `MIME"text/html"` - CSS wrapped in `<style>` tags
- `MIME"text/latex"` - LaTeX `\\newcommand` definitions

# Example
```julia
css = stylesheet("Dracula")
html_style = stylesheet(MIME("text/html"), "Nord")

# Custom prefix
css = stylesheet("Dracula"; classprefix="syntax")
# → pre.syntax { ... }
# → .syntax-c1 { ... }

# Use with class-based HTML output
code_html = highlight("text/html", code, :julia, "Dracula"; stylesheet=true)
full_html = stylesheet("text/html", "Dracula") * code_html
```
"""
function stylesheet(theme_name::String; classprefix::AbstractString = "hl")
    stylesheet(MIME("text/css"), theme_name; classprefix)
end

function stylesheet(mime, theme_name::String; classprefix::AbstractString = "hl")
    io = IOBuffer()
    stylesheet(io, mime, theme_name; classprefix)
    return String(take!(io))
end

function stylesheet(
    io::IO,
    mime::AbstractString,
    theme_name::String;
    classprefix::AbstractString = "hl",
)
    stylesheet(io, MIME(mime), theme_name; classprefix)
end

function stylesheet(
    io::IO,
    ::MIME"text/css",
    theme_name::String;
    classprefix::AbstractString = "hl",
)
    theme = load_theme(theme_name)

    # Base pre style
    println(io, "pre.$(classprefix) {")
    println(io, "  background-color: $(theme.background);")
    println(io, "  color: $(theme.foreground);")
    println(io, "  padding: 1em;")
    println(io, "  border-radius: 4px;")
    println(io, "  overflow-x: auto;")
    println(io, "}")

    # Color classes
    for i = 1:16
        println(io, ".$(classprefix)-c$i { color: $(theme.colors[i]); }")
    end

    return nothing
end

function stylesheet(
    io::IO,
    ::MIME"text/html",
    theme_name::String;
    classprefix::AbstractString = "hl",
)
    println(io, "<style>")
    stylesheet(io, MIME("text/css"), theme_name; classprefix)
    println(io, "</style>")
    return nothing
end

function stylesheet(
    io::IO,
    ::MIME"text/latex",
    theme_name::String;
    classprefix::AbstractString = "hl",
)
    theme = load_theme(theme_name)
    cmdprefix = uppercase(classprefix) * "C"

    println(io, "\\usepackage{xcolor}")
    println(io, "\\usepackage{listings}")
    println(io, "\\usepackage[listings,breakable]{tcolorbox}")
    println(io)

    # Define colors
    for i = 1:16
        r, g, b = hex_to_rgb(theme.colors[i])
        println(io, "\\definecolor{$(classprefix)c$i}{RGB}{$r,$g,$b}")
    end

    # Background/foreground
    r, g, b = hex_to_rgb(theme.background)
    println(io, "\\definecolor{$(classprefix)bg}{RGB}{$r,$g,$b}")
    r, g, b = hex_to_rgb(theme.foreground)
    println(io, "\\definecolor{$(classprefix)fg}{RGB}{$r,$g,$b}")

    println(io)

    # Command definitions for each color (use letters a-p since LaTeX commands can't have digits)
    for i = 1:16
        letter = color_to_letter(i)
        println(
            io,
            "\\newcommand{\\$(cmdprefix)$letter}[1]{\\textcolor{$(classprefix)c$i}{#1}}",
        )
    end

    println(io)

    # tcolorbox environment for code blocks (no white line artifacts)
    println(io, "\\newtcblisting{$(classprefix)code}{")
    println(io, "  colback=$(classprefix)bg,")
    println(io, "  colframe=$(classprefix)bg,")
    println(io, "  listing only,")
    println(io, "  breakable,")
    println(io, "  boxrule=0pt,")
    println(io, "  left=0.5em,")
    println(io, "  right=0.5em,")
    println(io, "  top=0.5em,")
    println(io, "  bottom=0.5em,")
    println(io, "  listing options={")
    println(io, "    basicstyle=\\ttfamily\\footnotesize\\color{$(classprefix)fg},")
    println(io, "    breaklines=true,")
    println(io, "    columns=fullflexible,")
    println(io, "    keepspaces=true,")
    println(io, "    showspaces=false,")
    println(io, "    showstringspaces=false,")
    println(io, "    escapeinside={(*@}{@*)},")
    println(io, "  }")
    println(io, "}")

    return nothing
end
