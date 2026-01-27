# Language resolution and discovery.

const LANGUAGE_ALIASES = Dict{String,String}(
    "js" => "javascript",
    "ts" => "typescript",
    "py" => "python",
    "rb" => "ruby",
    "yml" => "yaml",
    "rs" => "rust",
    "cs" => "c_sharp",
    "c++" => "cpp",
    "cxx" => "cpp",
    "sh" => "bash",
    "shell" => "bash",
    "zsh" => "bash",
    "jl" => "julia",
    "ml" => "ocaml",
    "f90" => "fortran",
    "f95" => "fortran",
)

"""
    extract_language_name(pkg::String) -> String

Extract language name from JLL package name (tree_sitter_X_jll -> X).
"""
function extract_language_name(pkg::String)
    m = match(r"^tree_sitter_(.+)_jll$", pkg)
    return m === nothing ? pkg : m.captures[1]
end

"""
    available_language_jlls() -> Vector{String}

Return all tree_sitter_*_jll packages available in registries.
"""
function available_language_jlls()
    jlls = String[]
    @static if VERSION >= v"1.7"
        for reg in Pkg.Registry.reachable_registries()
            for (uuid, regpkg) in reg
                name = regpkg.name
                # Match tree_sitter_<lang>_jll but exclude tree_sitter_jll itself
                if startswith(name, "tree_sitter_") &&
                   endswith(name, "_jll") &&
                   name != "tree_sitter_jll"
                    name in jlls || push!(jlls, name)
                end
            end
        end
    end
    return jlls
end

"""
    available_languages() -> Vector{String}

Return sorted list of language names available in registries.

Use this to discover installable grammar packages. Each name corresponds to
a `tree_sitter_<name>_jll` package that can be installed via `Pkg.add`.

See also: [`available_themes`](@ref)
"""
function available_languages()
    jlls = available_language_jlls()
    langs = [extract_language_name(j) for j in jlls]
    return sort!(unique!(langs))
end

"""
    suggest_language_jlls(query::String, jlls::Vector{String}; limit::Int=5) -> Vector{Tuple{String,String}}

Return (language_name, jll_package) pairs sorted by similarity to query.
Reduces limit when top match is much better than alternatives.
"""
function suggest_language_jlls(query::String, jlls::Vector{String}; limit::Int = 5)
    query_lower = lowercase(query)
    scored =
        [(levenshtein(query_lower, lowercase(extract_language_name(j))), j) for j in jlls]
    sort!(scored, by = first)

    # Reduce limit if top match is clearly better (distance diff >= 2)
    if length(scored) > 1 && scored[2][1] - scored[1][1] >= 2
        limit = min(limit, 3)
    end

    n = min(limit, length(scored))
    return [(extract_language_name(j), j) for (_, j) in scored[1:n]]
end

"""
    normalize_language(lang) -> Symbol

Normalize a language to a canonical Symbol (lowercase, alias-resolved).
"""
normalize_language(lang::Module) = Symbol(extract_language_name(string(nameof(lang))))
function normalize_language(lang::Union{Symbol,AbstractString})
    lang_str = lowercase(string(lang))
    lang_str = get(LANGUAGE_ALIASES, lang_str, lang_str)
    return Symbol(lang_str)
end

"""
    resolve_language(lang::Module) -> Module
    resolve_language(lang::Union{Symbol,AbstractString}) -> Module

Resolve a language specification to a JLL module.
Supports case-insensitive names and common aliases.
"""
resolve_language(lang::Module) = lang

function resolve_language(lang::Union{Symbol,AbstractString})
    # Normalize: lowercase and resolve aliases
    lang_str = lowercase(string(lang))
    lang_str = get(LANGUAGE_ALIASES, lang_str, lang_str)

    name = "tree_sitter_$(lang_str)_jll"
    pkgid = Base.identify_package(name)
    if pkgid === nothing
        available = available_language_jlls()
        if name in available
            error(
                "Language '$lang_str' requires package '$name'. Install with: Pkg.add(\"$name\")",
            )
        elseif isempty(available)
            error("Language '$lang_str' not found (no grammar packages found in registry)")
        else
            suggestions = suggest_language_jlls(lang_str, available)
            list = join(["  - $lang ($jll)" for (lang, jll) in suggestions], "\n")
            error(
                "Language '$lang_str' not found. Similar languages (install via Pkg.add):\n$list",
            )
        end
    end
    return Base.require(pkgid)
end
