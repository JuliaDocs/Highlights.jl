using Documenter
using Highlights
using Typst_jll
using tree_sitter_bash_jll, tree_sitter_go_jll, tree_sitter_javascript_jll
using tree_sitter_julia_jll, tree_sitter_python_jll, tree_sitter_r_jll, tree_sitter_rust_jll

# Generate standalone theme gallery
const DEMO_THEMES = [
    # Dark
    "Dracula",
    "Nord",
    "Monokai Dark",
    "Gruvbox Dark",
    "One Dark",
    "Solarized Dark",
    "Tokyo Night",
    "Catppuccin Mocha",
    "Github Dark",
    "Everforest Dark Hard",
    # Light
    "Github Light",
    "Solarized Light",
    "Gruvbox Material Light",
    "One Light",
    "Catppuccin Latte",
    "Tokyo Night Light",
]

const DEMO_SAMPLES = Dict(
    :julia => """
# Fibonacci sequence
function fib(n::Int)
    n <= 1 && return n
    return fib(n - 1) + fib(n - 2)
end

println("fib(10) = \$(fib(10))")
""",
    :python => """
# Fibonacci sequence
def fib(n):
    if n <= 1:
        return n
    return fib(n - 1) + fib(n - 2)

print(f"fib(10) = {fib(10)}")
""",
    :javascript => """
// Fibonacci sequence
function fib(n) {
    if (n <= 1) return n;
    return fib(n - 1) + fib(n - 2);
}

console.log(`fib(10) = \${fib(10)}`);
""",
    :rust => """
// Fibonacci sequence
fn fib(n: u32) -> u32 {
    if n <= 1 { return n; }
    fib(n - 1) + fib(n - 2)
}

fn main() {
    println!("fib(10) = {}", fib(10));
}
""",
    :go => """
// Fibonacci sequence
func fib(n int) int {
    if n <= 1 {
        return n
    }
    return fib(n-1) + fib(n-2)
}

fmt.Printf("fib(10) = %d\\n", fib(10))
""",
    :bash => """
# Fibonacci sequence
fib() {
    local n=\$1
    if (( n <= 1 )); then
        echo \$n
    else
        echo \$(( \$(fib \$((n-1))) + \$(fib \$((n-2))) ))
    fi
}

echo "fib(10) = \$(fib 10)"
""",
    :r => """
# Fibonacci sequence
fib <- function(n) {
    if (n <= 1) return(n)
    fib(n - 1) + fib(n - 2)
}

cat("fib(10) =", fib(10), "\\n")
""",
)

const LANG_ORDER = [:julia, :python, :javascript, :rust, :go, :bash, :r]
const LANG_LABELS = Dict(
    :julia => "Julia",
    :python => "Python",
    :javascript => "JS",
    :rust => "Rust",
    :go => "Go",
    :bash => "Bash",
    :r => "R",
)

open(joinpath(@__DIR__, "src", "gallery.html"), "w") do io
    println(
        io,
        """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Theme Gallery - Highlights.jl</title>
    <style>
        * { box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background: #0d1117;
            color: #c9d1d9;
            margin: 0;
            padding: 2rem;
            line-height: 1.6;
        }
        .container { max-width: 1200px; margin: 0 auto; }
        h1 {
            font-size: 2.5rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
            background: linear-gradient(135deg, #58a6ff, #a371f7);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .subtitle { color: #8b949e; margin-bottom: 3rem; font-size: 1.1rem; }
        .subtitle a { color: #58a6ff; text-decoration: none; }
        .subtitle a:hover { text-decoration: underline; }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(500px, 1fr));
            gap: 1.5rem;
        }
        .theme-card {
            border-radius: 12px;
            overflow: hidden;
            border: 1px solid #30363d;
        }
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.5rem 1rem;
            background: #161b22;
            border-bottom: 1px solid #30363d;
        }
        .theme-name { font-weight: 500; font-size: 0.9rem; }
        .tabs {
            display: flex;
            gap: 0.25rem;
        }
        .tab {
            padding: 0.25rem 0.5rem;
            font-size: 0.75rem;
            background: transparent;
            border: 1px solid #30363d;
            border-radius: 4px;
            color: #8b949e;
            cursor: pointer;
            transition: all 0.15s;
        }
        .tab:hover { color: #c9d1d9; border-color: #8b949e; }
        .tab.active { background: #30363d; color: #c9d1d9; }
        .code-panel { display: none; }
        .code-panel.active { display: block; }
        .theme-card pre {
            margin: 0 !important;
            border-radius: 0 !important;
            font-family: "JetBrains Mono", "Fira Code", Monaco, Consolas, monospace;
            font-size: 0.8rem;
            line-height: 1.5;
        }
        @media (max-width: 600px) {
            .grid { grid-template-columns: 1fr; }
            body { padding: 1rem; }
            h1 { font-size: 1.8rem; }
            .card-header { flex-direction: column; gap: 0.5rem; align-items: flex-start; }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Theme Gallery</h1>
        <p class="subtitle">
            Highlights.jl ships with $(length(Highlights.available_themes())) themes from the
            <a href="https://gogh-co.github.io/Gogh/" target="_blank">Gogh</a> project.
            Here are some popular ones.
            <a href="index.html">← Back to docs</a>
        </p>
        <div class="grid">""",
    )

    for (i, theme_name) in enumerate(DEMO_THEMES)
        card_id = "card$i"
        # Tab buttons
        tabs_html = join(
            [
                """<button class="tab$(lang == :julia ? " active" : "")" data-lang="$lang" onclick="showLang('$card_id', '$lang')">$(LANG_LABELS[lang])</button>"""
                for lang in LANG_ORDER
            ],
            "\n                    ",
        )

        # Code panels
        panels_html = join(
            [
                """<div class="code-panel$(lang == :julia ? " active" : "")" data-lang="$lang">$(highlight("text/html", DEMO_SAMPLES[lang], lang, theme_name))</div>"""
                for lang in LANG_ORDER
            ],
            "\n                ",
        )

        println(
            io,
            """
    <div class="theme-card" id="$card_id">
        <div class="card-header">
            <span class="theme-name">$theme_name</span>
            <div class="tabs">
            $tabs_html
            </div>
        </div>
        $panels_html
    </div>""",
        )
    end

    println(
        io,
        """
        </div>
    </div>
    <script>
    function showLang(cardId, lang) {
        const card = document.getElementById(cardId);
        card.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        card.querySelectorAll('.code-panel').forEach(p => p.classList.remove('active'));
        card.querySelector('.tab[data-lang=\"' + lang + '\"]').classList.add('active');
        card.querySelector('.code-panel[data-lang=\"' + lang + '\"]').classList.add('active');
    }
    </script>
</body>
</html>""",
    )
end

# Generate PDF demo via Typst
const PDF_THEMES = ["Dracula", "Nord", "Solarized Light", "Gruvbox Dark"]

open(joinpath(@__DIR__, "src", "demo.typ"), "w") do io
    println(
        io,
        """
#set page(margin: 1in)
#set text(font: "JetBrains Mono", size: 9pt)

#align(center)[
    #text(size: 24pt, weight: "bold")[Highlights.jl]
    #v(0.5em)
    #text(size: 12pt, fill: gray)[Syntax Highlighting Demo]
]

#v(2em)

This PDF was generated using Highlights.jl with Typst output.
Each section shows the same code in different themes and languages.

#v(1em)
""",
    )

    for theme in PDF_THEMES
        println(
            io,
            """
#heading(level: 2)[$theme]
#v(0.5em)
""",
        )
        for lang in [:julia, :python, :rust]
            label = LANG_LABELS[lang]
            code = highlight("text/typst", DEMO_SAMPLES[lang], lang, theme)
            println(
                io,
                """
#text(weight: "bold")[$label]
#block(fill: luma(245), inset: 8pt, radius: 4pt, width: 100%)[
$code
]
#v(0.5em)
""",
            )
        end
        println(io, "#pagebreak()")
    end
end

# Compile Typst to PDF
run(
    `$(Typst_jll.typst()) compile $(joinpath(@__DIR__, "src", "demo.typ")) $(joinpath(@__DIR__, "src", "demo.pdf"))`,
)

makedocs(
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    modules = [Highlights],
    sitename = "Highlights.jl",
    authors = "Michael Hatherly",
    pages = [
        "Home" => "index.md",
        "User Guide" => "guide.md",
        "Themes" => "themes.md",
        "Languages" => "languages.md",
        "Theme Gallery" => "demos.md",
        "API Reference" => "api.md",
    ],
)

# Copy standalone gallery and PDF to build
cp(
    joinpath(@__DIR__, "src", "gallery.html"),
    joinpath(@__DIR__, "build", "gallery.html");
    force = true,
)
cp(
    joinpath(@__DIR__, "src", "demo.pdf"),
    joinpath(@__DIR__, "build", "demo.pdf");
    force = true,
)

deploydocs(repo = "github.com/JuliaDocs/Highlights.jl.git")
