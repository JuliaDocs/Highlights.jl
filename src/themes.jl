# Theme loading from Gogh JSON files.

"""
    Theme

Represents a color theme with 16 ANSI colors and special colors.

# Fields
- `name::String`: Theme name
- `colors::Dict{Int,String}`: Maps color index (1-16) to hex color string
- `background::String`: Background color (hex)
- `foreground::String`: Default text color (hex)

# Custom Themes

Create custom themes by deriving from existing themes:

```julia
# Override specific colors
Theme("Dracula", colors = Dict(2 => "#ff0000"))

# Change background
Theme("Nord", background = "#1a1a1a")

# Give it a new name
Theme("Dracula", name = "MyDracula", colors = Dict(2 => "#ff0000"))

# Chain derivations
base = Theme("Dracula", background = "#1a1a1a")
custom = Theme(base, colors = Dict(3 => "#00ff00"))
```
"""
struct Theme
    name::String
    colors::Dict{Int,String}
    background::String
    foreground::String
end

function Theme(
    base::String;
    name::String = base,
    colors::Dict{Int,String} = Dict{Int,String}(),
    background::Union{String,Nothing} = nothing,
    foreground::Union{String,Nothing} = nothing,
)
    Theme(load_theme(base); name, colors, background, foreground)
end

function Theme(
    base::Theme;
    name::String = base.name,
    colors::Dict{Int,String} = Dict{Int,String}(),
    background::Union{String,Nothing} = nothing,
    foreground::Union{String,Nothing} = nothing,
)
    Theme(
        name,
        merge(base.colors, colors),
        something(background, base.background),
        something(foreground, base.foreground),
    )
end

const THEME_CACHE = Dict{String,Theme}()
const THEME_INDEX = Dict{String,String}()  # name → filename (basename)

function themes_dir()
    return joinpath(Artifacts.artifact"Gogh", "data", "json")
end

function populate_theme_index!()
    isempty(THEME_INDEX) || return
    for file in readdir(themes_dir())
        endswith(file, ".json") || continue
        data = JSON.parsefile(joinpath(themes_dir(), file))
        THEME_INDEX[data["name"]] = file
    end
end

populate_theme_index!()

"""
    available_themes() -> Vector{String}

Return a sorted list of all available theme names.
"""
function available_themes()
    sort(collect(keys(THEME_INDEX)))
end

"""
    color_distance(c1::AbstractString, c2::AbstractString) -> Float64

Compute perceptual distance between two hex colors.
"""
function color_distance(c1::AbstractString, c2::AbstractString)
    r1, g1, b1 = hex_to_rgb(c1)
    r2, g2, b2 = hex_to_rgb(c2)
    # Weighted euclidean distance (human eye is more sensitive to green)
    return sqrt(2*(r1-r2)^2 + 4*(g1-g2)^2 + 3*(b1-b2)^2)
end

"""
    parse_theme(data) -> Theme

Parse raw theme dictionary into a Theme struct.
"""
function parse_theme(data)
    colors = Dict{Int,String}()
    for i = 1:16
        key = "color_" * lpad(i, 2, '0')
        if haskey(data, key)
            colors[i] = data[key]
        else
            colors[i] = i <= 8 ? "#000000" : "#FFFFFF"
        end
    end

    background = get(data, "background", "#000000")
    foreground = get(data, "foreground", "#FFFFFF")

    # Fix comment color (index 1): pick best contrast between color_01 and color_09
    # If neither has sufficient contrast, blend foreground with background
    c1 = colors[1]
    c9 = colors[9]
    d1 = color_distance(c1, background)
    d9 = color_distance(c9, background)
    best_distance = max(d1, d9)
    if d9 > d1
        colors[1] = c9
    end
    # If best contrast is too low, create a muted foreground color
    if best_distance < 100
        r_bg, g_bg, b_bg = hex_to_rgb(background)
        r_fg, g_fg, b_fg = hex_to_rgb(foreground)
        # Blend 40% foreground, 60% background for a muted comment color
        r = round(Int, 0.4 * r_fg + 0.6 * r_bg)
        g = round(Int, 0.4 * g_fg + 0.6 * g_bg)
        b = round(Int, 0.4 * b_fg + 0.6 * b_bg)
        colors[1] = rgb_to_hex(r, g, b)
    end

    return Theme(data["name"], colors, background, foreground)
end

"""
    levenshtein(a::AbstractString, b::AbstractString) -> Int

Compute Levenshtein (edit) distance between two strings.
"""
function levenshtein(a::AbstractString, b::AbstractString)
    m, n = length(a), length(b)
    m == 0 && return n
    n == 0 && return m

    prev = collect(0:n)
    curr = similar(prev)

    for (i, a_char) in enumerate(a)
        curr[1] = i
        for (j, b_char) in enumerate(b)
            cost = a_char == b_char ? 0 : 1
            curr[j+1] = min(prev[j+1] + 1, curr[j] + 1, prev[j] + cost)
        end
        prev, curr = curr, prev
    end

    return prev[n+1]
end

"""
    suggest_themes(query::String, themes::Vector{String}; limit::Int=5) -> Vector{String}

Find themes most similar to query based on edit distance (case-insensitive).
"""
function suggest_themes(query::String, themes::Vector{String}; limit::Int = 5)
    query_lower = lowercase(query)
    scored = [(levenshtein(query_lower, lowercase(t)), t) for t in themes]
    sort!(scored, by = x -> (first(x), last(x)))
    return [t for (_, t) in scored[1:min(limit, length(scored))]]
end

"""
    load_theme(name::String) -> Theme

Load a theme by name or file path. Built-in themes are cached; file-based themes are not.
"""
function load_theme(name::String)
    haskey(THEME_CACHE, name) && return THEME_CACHE[name]

    # Check if it's a JSON file path (not cached - allows live editing)
    if endswith(name, ".json")
        is_file = try
            isfile(name)
        catch
            false
        end
        is_file && return parse_theme(JSON.parsefile(name))
    end

    if haskey(THEME_INDEX, name)
        data = JSON.parsefile(joinpath(themes_dir(), THEME_INDEX[name]))
        theme = parse_theme(data)
        THEME_CACHE[name] = theme
        return theme
    end

    suggestions = suggest_themes(name, collect(keys(THEME_INDEX)))
    suggestion_list = join(["  - $t" for t in suggestions], "\n")
    error("Theme '$name' not found. Similar themes:\n$suggestion_list")
end

"""
    clear_theme_cache!()

Clear the theme cache.
"""
function clear_theme_cache!()
    empty!(THEME_CACHE)
    return nothing
end
