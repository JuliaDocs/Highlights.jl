module Compiler

import ..Highlights: Str, AbstractLexer, definition
import ..Highlights.Tokens: Tokens, TokenValue, ERROR

type Mut{T}
    value::T
end

Base.getindex(m::Mut) = m.value
Base.setindex!(m::Mut, v) = m.value = v


immutable Token
    value::TokenValue
    first::Int
    last::Int
end


immutable Context
    source::Str
    pos::Mut{Int}
    length::Int
    tokens::Vector{Token}
    captures::Vector{UnitRange{Int}}
    Context(c::Context, len::Int) = new(c.source, c.pos, len, c.tokens, c.captures)
    Context(s::AbstractString) = new(s, Mut(1), endof(s), [], [])
end

isdone(ctx::Context) = ctx.pos[] > ctx.length


immutable State{s} end


const NULL_RANGE = 0:0
valid(r::Range) = r !== NULL_RANGE

function nullmatch(r::Regex, ctx::Context)
    local source = ctx.source
    local index = ctx.pos[]
    Base.compile(r)
    if Base.PCRE.exec(r.regex, source, index - 1, r.match_options, r.match_data)
        local range = Int(r.ovec[1] + 1):Int(r.ovec[2])
        local count = div(length(r.ovec), 2) - 1
        if count > 0
            length(ctx.captures) < count && resize!(ctx.captures, count)
            for i = 1:count
                ctx.captures[i] = r.ovec[2i + 1] == Base.PCRE.UNSET ?
                    NULL_RANGE : (Int(r.ovec[2i + 1] + 1):Int(r.ovec[2i + 2]))
            end
        end
        return range
    else
        return NULL_RANGE
    end
end
nullmatch(f::Function, ctx::Context) = f(ctx)


function update!(ctx::Context, range::Range, token::TokenValue)
    local pos = prevind(ctx.source, ctx.pos[] + length(range))
    if !isempty(ctx.tokens) && ctx.tokens[end].value == token
        ctx.tokens[end] = Token(token, ctx.tokens[end].first, pos)
    else
        ctx.pos[] <= pos && push!(ctx.tokens, Token(token, ctx.pos[], pos))
    end
    ctx.pos[] = nextind(ctx.source, pos)
    return ctx
end

function update!(ctx::Context, range::Range, lexer::Type, state = State{:root}())
    local pos = ctx.pos[] + length(range)
    lex!(Context(ctx, last(range)), lexer, state)
    ctx.pos[] = pos
    return ctx
end

function error!(ctx::Context)
    push!(ctx.tokens, Token(Tokens.ERROR, ctx.pos[], ctx.pos[]))
    ctx.pos[] = nextind(ctx.source, ctx.pos[])
    return ctx
end


lex{T <: AbstractLexer}(s::AbstractString, l::Type{T}) = lex!(Context(s), l, State{:root}())

@generated function lex!{__this__, s}(ctx::Context, ::Type{__this__}, ::State{s})
    quote
        # The main lexer loop for each state.
        while !isdone(ctx)
            $(compile_patterns(__this__, s))
            # When no patterns match the current `ctx` position then push an error token
            # and then move on to the next position.
            error!(ctx)
        end
        return ctx
    end
end

function get_tokens{L <: AbstractLexer}(::Type{L})
    local tokens = get(definition(L), :tokens, Dict{Symbol, Any}())
    return merge(get_tokens(supertype(L)), tokens)
end
get_tokens(::Type{Any}) = Dict{Symbol, Any}()

getrules(lexer, state) = get(get_tokens(lexer), state, [])

function compile_patterns(T::Type, s::Symbol, rules::Vector = getrules(T, s))
    local out = Expr(:block)
    for rule in rules
        push!(out.args, compile_rule(T, s, rule))
    end
    return out
end

compile_rule(T::Type, s::Symbol, rule::Tuple) = compile_rule(T, s, rule...)

# Include the rules from state `inc` in the current state `s`.
#
# `:__inherit__` is special cased to include the rules for the current state `s` of the
# ancestor of the current lexer `T`.
function compile_rule(T::Type, s::Symbol, inc::Symbol)
    (ty, st) = inc === :__inherit__ ? (supertype(T), s) : (T, inc)
    return compile_patterns(T, s, getrules(ty, st))
end

# Inherit the rules from lexer `T` and it's state `s`.
compile_rule{T}(::Type, s::Symbol, ::Type{T}) = compile_patterns(T, s, getrules(T, s))

# Build a matcher block that tries a match and either succeeds and binds the result,
# or fails an moves on to the next block.
function compile_rule(T::Type, s::Symbol, match, bindings, target = :__none__)
    quote
        let range = nullmatch($(prepare_match(match)), ctx)
            if valid(range)
                $(prepare_bindings(bindings))
                $(prepare_target(T, s, target))
                continue # Might be skipped, depending of `prepare_target` result.
            end
        end
    end
end


# Regex matchers need to be 'left-anchored' with `\G` to work correctly.
prepare_match(r::Regex) = Regex("\\G$(r.pattern)", r.compile_options, r.match_options)
prepare_match(f::Function) = f


# Lex the `range` using lexer `L`, starting in state `:root`.
prepare_bindings{L <: AbstractLexer}(::Type{L}) =
    :(update!(ctx, range, $(L), $(State{:root}())))

# Bind each of a group of captured matches to each element in the tuple `t`.
function prepare_bindings(t::Tuple)
    local out = Expr(:block)
    for (nth, token) in enumerate(t)
        push!(out.args, :(update!(ctx, ctx.captures[$(nth)], $(token))))
    end
    return out
end

# The common bind case: bind matched range to token `s`.
prepare_bindings(s::Union{Symbol, TokenValue}) = :(update!(ctx, range, $(s)))


# Do nothing, pop the state, push another one on, or enter a new one entirely.
function prepare_target(T, s::Symbol, target::Symbol)
    target === :__none__ && return Expr(:block)
    target === :__pop__  && return Expr(:break)
    local state = target === :__push__ ? s : target
    return :(lex!(ctx, $(T), $(State{state}())))
end

# A tuple of states to enter must be done in 'reverse' order.
function prepare_target(T, s::Symbol, ts::Tuple)
    local out = Expr(:block)
    for t in ts
        unshift!(out.args, prepare_target(T, s, t))
    end
    return out
end

# Useful function for checking tokens.
function debug(io::IO, src::AbstractString, lexer)
    local tokens = lex(src, lexer).tokens
    local padding = mapreduce(t -> length(string(t.value)), max, 0, tokens)
    for each in tokens
        print(io, lpad(string(each.value), padding), " := ")
        println(io, repr(SubString(src, each.first, each.last)))
    end
end
debug(src::AbstractString, lexer) = debug(STDOUT, src, lexer)

end # module
