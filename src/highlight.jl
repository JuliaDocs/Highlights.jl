# Core highlighting logic: tokens, deduplication, capture mapping.

"""
    HighlightToken

Represents a syntax-highlighted token with position and AST information.

# Fields
- `text`: The token text
- `capture`: Tree-sitter capture name (e.g., "function.call")
- `byte_range`: Start and end byte positions in source
- `node`: Original TreeSitter.Node for AST navigation (Nothing for synthetic tokens)
"""
struct HighlightToken
    text::String
    capture::String
    byte_range::Tuple{Int,Int}
    node::Union{TreeSitter.Node,Nothing}
end

"""
    default_capture_colors() -> Dict{String,Int}

Default mapping from tree-sitter capture names to ANSI color indices (1-16).
"""
function default_capture_colors()
    return Dict{String,Int}(
        # Keywords
        "keyword" => 2,
        "keyword.return" => 2,
        "keyword.function" => 2,
        "keyword.operator" => 2,
        "conditional" => 2,
        "repeat" => 2,
        "include" => 2,

        # Functions
        "function" => 5,
        "function.builtin" => 13,
        "function.call" => 5,
        "function.macro" => 6,
        "method" => 5,
        "method.call" => 5,
        "constructor" => 5,

        # Types
        "type" => 7,
        "type.builtin" => 15,
        "type.definition" => 7,

        # Variables
        "variable" => 8,
        "variable.builtin" => 14,
        "variable.parameter" => 8,
        "property" => 8,

        # Constants
        "constant" => 4,
        "constant.builtin" => 12,
        "boolean" => 4,
        "number" => 4,

        # Strings
        "string" => 3,
        "string.special" => 11,
        "string.escape" => 6,
        "character" => 3,

        # Comments
        "comment" => 1,

        # Operators/punctuation
        "operator" => 8,
        "punctuation" => 8,
        "punctuation.bracket" => 8,
        "punctuation.delimiter" => 8,

        # Other
        "macro" => 6,
        "module" => 7,
        "namespace" => 7,
        "error" => 10,
    )
end

"""
    default_capture_priorities() -> Dict{String,Int}

Default priority mapping for capture names. Higher = wins when overlapping.
"""
function default_capture_priorities()
    return Dict{String,Int}(
        "keyword" => 100,
        "keyword.return" => 100,
        "keyword.function" => 100,
        "keyword.operator" => 100,
        "conditional" => 100,
        "repeat" => 100,
        "include" => 100,
        "function" => 90,
        "function.builtin" => 90,
        "function.call" => 90,
        "function.macro" => 90,
        "method" => 90,
        "method.call" => 90,
        "constructor" => 90,
        "type" => 80,
        "type.builtin" => 80,
        "type.definition" => 80,
        "module" => 80,
        "namespace" => 80,
        "string" => 70,
        "string.special" => 70,
        "string.escape" => 75,
        "character" => 70,
        "number" => 70,
        "boolean" => 70,
        "constant" => 60,
        "constant.builtin" => 60,
        "comment" => 50,
        "macro" => 40,
        "operator" => 20,
        "punctuation" => 20,
        "punctuation.bracket" => 20,
        "punctuation.delimiter" => 20,
        "variable" => 10,
        "variable.builtin" => 15,
        "variable.parameter" => 10,
        "property" => 10,
        "error" => 1000,
    )
end

"""
    get_capture_color(capture_name::AbstractString, mapping::Dict) -> Int

Get color index for a capture name, with hierarchical fallback.
"""
function get_capture_color(capture_name::AbstractString, mapping::Dict)
    haskey(mapping, capture_name) && return mapping[capture_name]

    parts = split(capture_name, '.')
    while length(parts) > 1
        pop!(parts)
        parent_name = join(parts, '.')
        haskey(mapping, parent_name) && return mapping[parent_name]
    end

    return 8  # default foreground
end

"""
    get_capture_priority(capture_name::AbstractString, priorities::Dict) -> Int

Get priority for a capture name, with hierarchical fallback.
"""
function get_capture_priority(capture_name::AbstractString, priorities::Dict)
    haskey(priorities, capture_name) && return priorities[capture_name]

    parts = split(capture_name, '.')
    while length(parts) > 1
        pop!(parts)
        parent_name = join(parts, '.')
        haskey(priorities, parent_name) && return priorities[parent_name]
    end

    return 5  # default priority
end

"""
    deduplicate_tokens(tokens::Vector{HighlightToken}, priorities::Dict) -> Vector{HighlightToken}

Layer overlapping tokens, preferring more specific (shorter) tokens.
For identical ranges, highest priority wins.
"""
function deduplicate_tokens(tokens::Vector{HighlightToken}, priorities::Dict)
    isempty(tokens) && return tokens

    # Handle identical ranges by priority
    range_map = Dict{Tuple{Int,Int},HighlightToken}()
    for token in tokens
        range = token.byte_range
        if haskey(range_map, range)
            existing = range_map[range]
            if get_capture_priority(token.capture, priorities) >
               get_capture_priority(existing.capture, priorities)
                range_map[range] = token
            end
        else
            range_map[range] = token
        end
    end

    unique_tokens = collect(values(range_map))
    isempty(unique_tokens) && return HighlightToken[]

    # For each byte position, find most specific (shortest) covering token
    position_map = Dict{Int,Tuple{HighlightToken,Int}}()

    for token in unique_tokens
        start_pos, end_pos = token.byte_range
        range_length = end_pos - start_pos + 1

        for pos = start_pos:end_pos
            if haskey(position_map, pos)
                _, existing_length = position_map[pos]
                if range_length < existing_length
                    position_map[pos] = (token, range_length)
                end
            else
                position_map[pos] = (token, range_length)
            end
        end
    end

    # Build segments from consecutive positions with same token
    result = HighlightToken[]
    positions = sort(collect(keys(position_map)))
    isempty(positions) && return result

    current_token = position_map[positions[1]][1]
    segment_start = positions[1]

    for i = 2:length(positions)
        pos = positions[i]
        token_at_pos = position_map[pos][1]

        if token_at_pos.capture != current_token.capture ||
           token_at_pos.byte_range != current_token.byte_range ||
           pos != positions[i-1] + 1

            segment_end = positions[i-1]
            segment_text = current_token.text
            if segment_start != current_token.byte_range[1] ||
               segment_end != current_token.byte_range[2]
                offset = segment_start - current_token.byte_range[1]
                seg_length = segment_end - segment_start + 1
                segment_text = current_token.text[(offset+1):(offset+seg_length)]
            end

            push!(
                result,
                HighlightToken(
                    segment_text,
                    current_token.capture,
                    (segment_start, segment_end),
                    current_token.node,
                ),
            )

            current_token = token_at_pos
            segment_start = pos
        end
    end

    # Last segment
    segment_end = positions[end]
    segment_text = current_token.text
    if segment_start != current_token.byte_range[1] ||
       segment_end != current_token.byte_range[2]
        offset = segment_start - current_token.byte_range[1]
        seg_length = segment_end - segment_start + 1
        segment_text = current_token.text[(offset+1):(offset+seg_length)]
    end
    push!(
        result,
        HighlightToken(
            segment_text,
            current_token.capture,
            (segment_start, segment_end),
            current_token.node,
        ),
    )

    return result
end

"""
    highlight_tokens(parser::TreeSitter.Parser, query::TreeSitter.Query, source::AbstractString;
                     priorities::Dict=default_capture_priorities()) -> Vector{HighlightToken}

Extract highlight tokens from source code, sorted by position.
"""
function highlight_tokens(
    parser::TreeSitter.Parser,
    query::TreeSitter.Query,
    source::AbstractString;
    priorities::Dict = default_capture_priorities(),
)
    tokens = HighlightToken[]
    tree = Base.parse(parser, source)

    for m in eachmatch(query, tree)
        if TreeSitter.predicate(query, m, source)
            for c in TreeSitter.captures(m)
                capture_name = TreeSitter.capture_name(query, c)
                text = TreeSitter.slice(source, c.node)
                range = TreeSitter.byte_range(c.node)
                push!(tokens, HighlightToken(text, capture_name, range, c.node))
            end
        end
    end

    sort!(tokens, by = t -> t.byte_range[1])
    return deduplicate_tokens(tokens, priorities)
end
