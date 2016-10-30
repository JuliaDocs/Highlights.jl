module Compiler

using Compat

import ..Highlights: Str, AbstractLexer
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

function metadata end
function lex! end

# Load all supertypes' metadata.
getdata(T) = getdata!(ObjectIdDict(), T)
getdata!(d, ::Type{AbstractLexer}) = d
getdata!(d, lxr) = (getdata!(d, supertype(lxr)); d[lxr] = metadata(lxr); d)

immutable LexerData
    name::Str
    aliases::Vector{Str}
    filenames::Vector{Str}
    description::Str
    comments::Str
    tokens::Dict{Symbol, Vector{Any}}

    function LexerData(dict::Dict)
        local name = get(dict, :name, "")
        local aliases = get(dict, :aliases, Str[])
        local filenames = get(dict, :filenames, Str[])
        local description = get(dict, :description, "")
        local comments = get(dict, :comments, "")
        local tokens = get(dict, :tokens, Dict{Symbol, Vector{Any}}())
        return new(name, aliases, filenames, description, comments, tokens)
    end
end

function compile_lexer(mod::Module, T)
    local data = metadata(T)
    for state in keys(data.tokens)
        local func = quote
            function $(Compiler).lex!(ctx::$(Context), ::Type{$T}, ::$(State{state}))
                const S = $(Meta.quot(state))
                $(compile(T, state, getdata(T)))
            end
        end
        eval(mod, func)
        Base.precompile(lex!, (Context, Type{T}, State{state}))
    end
end

function getrules(T::Type, S::Symbol, data::ObjectIdDict)
    haskey(data, T) || return Any[]
    local lexer = data[T]
    haskey(lexer.tokens, S) ? lexer.tokens[S] : return Any[]
end

function compile(T::Type, S::Symbol, data::ObjectIdDict)
    quote
        const T = $T
        while !$(Compiler).isdone(ctx)
            $(compile_rules(T, S, data, getrules(T, S, data)))
            $(Compiler).error!(ctx)
        end
        ctx
    end
end

function compile_rules(T::Type, S::Symbol, data::ObjectIdDict, rules::Vector)
    local ex = Expr(:block)
    for each in getrules(T, S, data)
        push!(ex.args, compile_rule(T, S, data, each))
    end
    return ex
end

function compile_rule(T, S, data, rule::Symbol)
    ty, st = rule === :__inherit__ ? (supertype(T), S) : (T, rule)
    # return compile_rules(T, S, data, getrules(ty, st, data))
    local ex = Expr(:block)
    for each in getrules(ty, st, data)
        push!(ex.args, compile_rule(T, S, data, each))
    end
    return ex
end
compile_rule(T, S, data, rule::Tuple) = compile_match(T, S, data, rule...)

function compile_match(T, S, data, match, bindings, target = :__none__)
    quote
        let range = $(Compiler).nullmatch($(prepare_match(match)), ctx)
            if $(Compiler).valid(range)
                $(prepare_bindings(bindings))
                $(prepare_target(T, S, target))
                continue
            end
        end
    end
end

# Regex matchers need to be 'left-anchored' with `\G` to work correctly.
prepare_match(r::Regex) = Regex("\\G$(r.pattern)", r.compile_options, r.match_options)
prepare_match(f::Function) = f

function prepare_bindings(tuple::Tuple)
    local block = Expr(:block)
    for (nth, element) in enumerate(tuple)
        push!(block.args, prepare_binding(element, :(ctx.captures[$(nth)])))
    end
    return block
end
prepare_bindings(other) = prepare_binding(other, :range)

# A token such as `TEXT` or `NUMBER`.
prepare_binding(t::TokenValue, range) = :($(Compiler).update!(ctx, $range, $t))
# Call different lexer's `:root` state.
prepare_binding{L}(::Type{L}, range) = :($(Compiler).update!(ctx, $range, $L, $(State{:root}())))
# Call current lexer in state `S`.
prepare_binding(S::Symbol, range) = :($(Compiler).update!(ctx, $range, T, $(State{S}())))
# Call different lexer's state `p.second`.
prepare_binding(p::Pair, range) = :($(Compiler).update!(ctx, $range, $(first(p)), $(State{last(p)}())))

# Do nothing, pop the state, push another one on, or enter a new one entirely.
function prepare_target(T, s::Symbol, target::Symbol)
    target === :__none__ && return Expr(:block)
    target === :__pop__  && return Expr(:break)
    local state = target === :__push__ ? s : target
    return :($(Compiler).lex!(ctx, $(T), $(State{state}())))
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
