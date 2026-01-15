# Segment types for preprocessors

"""
    Segment

Abstract type for preprocessor output segments.
"""
abstract type Segment end

"""
    CodeSegment

A code block to be syntax-highlighted with TreeSitter.

# Fields
- `text::String`: Source code
- `language::Symbol`: Language to highlight as (e.g., `:julia`, `:bash`)
- `line_prefixes::Vector{Tuple{String,Int}}`: (prefix, color) for each line (e.g., continuation prompts)
"""
struct CodeSegment <: Segment
    text::String
    language::Symbol
    line_prefixes::Vector{Tuple{String,Int}}
end
CodeSegment(text::AbstractString, lang::Symbol) =
    CodeSegment(text, lang, Tuple{String,Int}[])

"""
    StyledSegment

A text block with a single color (no syntax highlighting).

# Fields
- `text::String`: Text content
- `color::Int`: Theme color index (1-16), or 0 for foreground
"""
struct StyledSegment <: Segment
    text::String
    color::Int
end

# Preprocessors for composite languages (REPL sessions, etc.)

"""
    ReplMode

Configuration for a REPL prompt mode.

# Fields
- `pattern::Regex`: Pattern to match the prompt (must capture the code after prompt)
- `prompt::String`: The prompt string to display
- `color::Int`: Color index for the prompt
- `language::Union{Symbol,Nothing}`: Language for syntax highlighting, or nothing for plain text
"""
struct ReplMode
    pattern::Regex
    prompt::String
    color::Int
    language::Union{Symbol,Nothing}
end

"""
    ReplConfig

Configuration for a REPL preprocessor.

# Fields
- `modes::Vector{ReplMode}`: Prompt modes (checked in order)
- `continuation::Union{Regex,Nothing}`: Pattern for continuation lines (must capture code)
- `continuation_prompt::String`: Prompt to display for continuation lines
"""
struct ReplConfig
    modes::Vector{ReplMode}
    continuation::Union{Regex,Nothing}
    continuation_prompt::String
end

# Julia REPL config
const JLCON_CONFIG = ReplConfig(
    [
        ReplMode(r"^(julia)> (.*)$", "julia> ", 11, :julia),      # bright green
        ReplMode(r"^(help\?)> (.*)$", "help?> ", 12, :julia),     # bright yellow
        ReplMode(r"^(shell)> (.*)$", "shell> ", 10, :bash),       # bright red
        ReplMode(r"^((?:\([^)]+\) )?pkg)> (.*)$", "", 13, nothing), # bright blue, dynamic prompt
    ],
    r"^(       .*)$",  # 7-space continuation
    "",  # continuation keeps original indentation
)

# Python REPL config
const PYCON_CONFIG = ReplConfig(
    [ReplMode(r"^>>> (.*)$", ">>> ", 12, :python)],  # bright yellow
    r"^\.\.\. (.*)$",
    "... ",
)

# R REPL config
const RCON_CONFIG = ReplConfig(
    [ReplMode(r"^> (.*)$", "> ", 13, :r)],  # bright blue
    r"^\+ (.*)$",
    "+ ",
)

"""
    repl_preprocess(source::AbstractString, config::ReplConfig) -> Vector{Segment}

Generic REPL session preprocessor. Handles prompts, continuations, and output.
"""
function repl_preprocess(source::AbstractString, config::ReplConfig)
    segments = Segment[]
    code_buf = IOBuffer()
    output_buf = IOBuffer()
    line_prefixes = Tuple{String,Int}[]
    current_lang = nothing
    current_color = 0

    function flush_output!()
        s = String(take!(output_buf))
        isempty(s) || push!(segments, StyledSegment(s, 0))
    end

    function flush_code!()
        s = String(take!(code_buf))
        if !isempty(s)
            s *= "\n"
            if current_lang === nothing
                push!(segments, StyledSegment(s, 0))
            else
                push!(segments, CodeSegment(s, current_lang, copy(line_prefixes)))
            end
        end
        empty!(line_prefixes)
    end

    for line in eachline(IOBuffer(source))
        # Check each prompt mode
        matched = false
        for mode in config.modes
            m = match(mode.pattern, line)
            if m !== nothing
                flush_output!()
                flush_code!()

                # Determine prompt text (use captured group for dynamic prompts like pkg)
                prompt_text = isempty(mode.prompt) ? m.captures[1] * "> " : mode.prompt
                code_text = m.captures[end]  # last capture is always the code

                push!(segments, StyledSegment(prompt_text, mode.color))
                current_lang = mode.language
                current_color = mode.color
                print(code_buf, code_text)
                matched = true
                break
            end
        end
        matched && continue

        # Check continuation
        if config.continuation !== nothing
            m = match(config.continuation, line)
            if m !== nothing
                flush_output!()
                # Add newline to code and track continuation prefix
                println(code_buf)
                push!(line_prefixes, (config.continuation_prompt, current_color))
                print(code_buf, m.captures[1])
                continue
            end
        end

        # Blank line in middle of code - keep as continuation
        if position(code_buf) > 0 && isempty(line)
            println(code_buf)
            push!(line_prefixes, ("", current_color))
            continue
        end

        # Output line
        flush_code!()
        println(output_buf, line)
    end

    flush_code!()
    flush_output!()
    return segments
end

"""
    jlcon_preprocess(source::AbstractString) -> Vector{Segment}

Preprocess Julia REPL (jlcon) sessions into segments.

Recognizes four prompt modes:
- `julia>` - Normal mode (green, highlighted as Julia)
- `help?>` - Help mode (yellow, highlighted as Julia)
- `shell>` - Shell mode (red, highlighted as Bash)
- `pkg>` - Package mode (blue, plain text)
"""
jlcon_preprocess(source::AbstractString) = repl_preprocess(source, JLCON_CONFIG)

"""
    pycon_preprocess(source::AbstractString) -> Vector{Segment}

Preprocess Python REPL (pycon) sessions into segments.

- `>>> ` - Primary prompt (yellow)
- `... ` - Continuation prompt (yellow)
"""
pycon_preprocess(source::AbstractString) = repl_preprocess(source, PYCON_CONFIG)

"""
    rcon_preprocess(source::AbstractString) -> Vector{Segment}

Preprocess R REPL (rcon) sessions into segments.

- `> ` - Primary prompt (blue)
- `+ ` - Continuation prompt (blue)
"""
rcon_preprocess(source::AbstractString) = repl_preprocess(source, RCON_CONFIG)

"""
    preprocessor(::MIME) -> Union{Function, Nothing}

Return the preprocessor function for a language MIME type, or nothing if none.

Users can extend for custom pseudo-languages:
```julia
Highlights.preprocessor(::MIME"text/myrepl") = my_repl_preprocess
```
"""
preprocessor(::MIME) = nothing
preprocessor(::MIME"text/jlcon") = jlcon_preprocess
preprocessor(::MIME"text/pycon") = pycon_preprocess
preprocessor(::MIME"text/rcon") = rcon_preprocess
