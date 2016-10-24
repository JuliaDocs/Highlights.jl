"""
This submodule provides a collection of *token* names for use in lexer and theme
definitions. Additional tokens can be defined using the [`@tokengroup`](@ref) macro.
"""
module Tokens

using DocStringExtensions

export @tokengroup

immutable TokenValue
    value::UInt
end
TokenValue(s::Symbol) = TokenValue(hash(s))

function parent(s::Symbol)
    local p = Symbol(join(split(string(s), '_')[1:end-1]))
    return p === Symbol("") ? :TEXT : p
end

nameof(t::TokenValue) = get(tokengroup(AbstractTokenGroup), t, Symbol("???"))

Base.show(io::IO, t::TokenValue) = print(io, '<', nameof(t), '>')

abstract AbstractTokenGroup

tokens() = tokengroup(AbstractTokenGroup)

function tokengroup(::Type{AbstractTokenGroup})
    local dict = Dict{TokenValue, Symbol}()
    for each in subtypes(AbstractTokenGroup)
        merge!(dict, tokengroup(each))
    end
    return dict
end

"""
$(SIGNATURES)

Define a new group of tokens with the given group `name` and individual names
`tokens` where `tokens` is an array literal containing valid identifiers.

# Examples

```julia
using Highlights.Tokens

@tokengroup CustomGroup [
    FOO,
    BAR,
    BAZ,
]
```
"""
macro tokengroup(name, tokens)
    local mapping = Dict{TokenValue, Symbol}()
    local block = Expr(:block)
    for each in tokens.args
        if isa(each, Symbol)
            local token = TokenValue(each)
            mapping[token] = each
            push!(block.args, :(export $(esc(each))))
            push!(block.args, :(const $(esc(each)) = $(token)))
        else
            error("`$each` is not a `Symbol`.")
        end
    end
    quote
        abstract $(esc(name)) <: $(AbstractTokenGroup)
        $(Tokens).tokengroup(::Type{$(esc(name))}) = $(mapping)
        $(block)
        nothing
    end
end

@tokengroup DefaultTokens [
    TEXT
    WHITESPACE
    ESCAPE
    ERROR
    OTHER

    KEYWORD
    KEYWORD_CONSTANT
    KEYWORD_DECLARATION
    KEYWORD_NAMESPACE
    KEYWORD_PSEUDO
    KEYWORD_RESERVED
    KEYWORD_TYPE

    NAME
    NAME_ATTRIBUTE
    NAME_BUILTIN
    NAME_BUILTIN_PSEUDO
    NAME_CLASS
    NAME_CONSTANT
    NAME_DECORATOR
    NAME_ENTITY
    NAME_EXCEPTION
    NAME_FUNCTION
    NAME_FUNCTION_MAGIC
    NAME_PROPERTY
    NAME_LABEL
    NAME_NAMESPACE
    NAME_OTHER
    NAME_TAG
    NAME_VARIABLE
    NAME_VARIABLE_CLASS
    NAME_VARIABLE_GLOBAL
    NAME_VARIABLE_INSTANCE
    NAME_VARIABLE_MAGIC

    LITERAL
    LITERAL_DATE

    STRING
    STRING_AFFIX
    STRING_BACKTICK
    STRING_CHAR
    STRING_DELIMITER
    STRING_DOC
    STRING_DOUBLE
    STRING_ESCAPE
    STRING_HEREDOC
    STRING_INTERPOL
    STRING_OTHER
    STRING_REGEX
    STRING_SINGLE
    STRING_SYMBOL

    NUMBER
    NUMBER_BIN
    NUMBER_FLOAT
    NUMBER_HEX
    NUMBER_INTEGER
    NUMBER_INTEGER_LONG
    NUMBER_OCT

    OPERATOR
    OPERATOR_WORD

    PUNCTUATION

    COMMENT
    COMMENT_HASHBANG
    COMMENT_MULTILINE
    COMMENT_PREPROC
    COMMENT_PREPROCFILE
    COMMENT_SINGLE
    COMMENT_SPECIAL

    GENERIC
    GENERIC_DELETED
    GENERIC_EMPH
    GENERIC_ERROR
    GENERIC_HEADING
    GENERIC_INSERTED
    GENERIC_OUTPUT
    GENERIC_PROMPT
    GENERIC_STRONG
    GENERIC_SUBHEADING
    GENERIC_TRACEBACK
]

end
