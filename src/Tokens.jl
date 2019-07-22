"""
This submodule provides a collection of *token* names for use in lexer and theme
definitions. The table shown below lists all the exported tokens as well as the
abbreviations used when printing stylesheets and highlighted source code.

$(TABLE)
"""
module Tokens

import ..Highlights

const __TOKENS__ = [
    :TEXT
    :WHITESPACE
    :ESCAPE
    :ERROR
    :OTHER

    :KEYWORD
    :KEYWORD_CONSTANT
    :KEYWORD_DECLARATION
    :KEYWORD_NAMESPACE
    :KEYWORD_PSEUDO
    :KEYWORD_RESERVED
    :KEYWORD_TYPE

    :NAME
    :NAME_ATTRIBUTE
    :NAME_BUILTIN
    :NAME_BUILTIN_PSEUDO
    :NAME_CLASS
    :NAME_CONSTANT
    :NAME_DECORATOR
    :NAME_ENTITY
    :NAME_EXCEPTION
    :NAME_FUNCTION
    :NAME_FUNCTION_MAGIC
    :NAME_PROPERTY
    :NAME_LABEL
    :NAME_NAMESPACE
    :NAME_OTHER
    :NAME_TAG
    :NAME_VARIABLE
    :NAME_VARIABLE_CLASS
    :NAME_VARIABLE_GLOBAL
    :NAME_VARIABLE_INSTANCE
    :NAME_VARIABLE_MAGIC

    :LITERAL
    :LITERAL_DATE

    :STRING
    :STRING_AFFIX
    :STRING_BACKTICK
    :STRING_CHAR
    :STRING_DELIMITER
    :STRING_DOC
    :STRING_DOUBLE
    :STRING_ESCAPE
    :STRING_HEREDOC
    :STRING_INTERPOL
    :STRING_OTHER
    :STRING_REGEX
    :STRING_SINGLE
    :STRING_SYMBOL

    :NUMBER
    :NUMBER_BIN
    :NUMBER_FLOAT
    :NUMBER_HEX
    :NUMBER_INTEGER
    :NUMBER_INTEGER_LONG
    :NUMBER_OCT

    :OPERATOR
    :OPERATOR_WORD

    :PUNCTUATION

    :COMMENT
    :COMMENT_HASHBANG
    :COMMENT_MULTILINE
    :COMMENT_PREPROC
    :COMMENT_PREPROCFILE
    :COMMENT_SINGLE
    :COMMENT_SPECIAL

    :GENERIC
    :GENERIC_DELETED
    :GENERIC_EMPH
    :GENERIC_ERROR
    :GENERIC_HEADING
    :GENERIC_INSERTED
    :GENERIC_OUTPUT
    :GENERIC_PROMPT
    :GENERIC_STRONG
    :GENERIC_SUBHEADING
    :GENERIC_TRACEBACK
]

const __INDICES__ = Dict([(s, n) for (n, s) in enumerate(__TOKENS__)])
const __FALLBACKS__ = zeros(Int, length(__TOKENS__))

struct TokenValue
    value::Int
end
TokenValue(s::Symbol) = TokenValue(__INDICES__[s])

function parent(s::Symbol)
    p = join(split(string(s), '_')[1:end-1], '_')
    return isempty(p) ? :TEXT : Symbol(p)
end

Base.show(io::IO, t::TokenValue) = print(io, '<', __TOKENS__[t.value], '>')

for (n, each) in enumerate(__TOKENS__)
    __FALLBACKS__[n] = __INDICES__[parent(each)]
    @eval export $each
    @eval const $each = TokenValue($n)
end

# Shortnames.

const __SHORTNAMES__ = Symbol[]

let cache = Dict{Symbol, Int}()
    for (nth, each) in enumerate(__TOKENS__)
        short = Symbol(join(map(first, split(lowercase(string(each)), '_'))))
        if haskey(cache, short)
            cache[short] += 1
            push!(__SHORTNAMES__, Symbol(string(short, Char(cache[short] + Int('A') - 1))))
        else
            cache[short] = 1
            push!(__SHORTNAMES__, short)
        end
    end
    # Check that we've actually got a unique set of shortnames.
    @assert unique(__SHORTNAMES__) == __SHORTNAMES__
end

# Make a table to include in the module's docstring.

const TABLE =
    let buffer = IOBuffer(),
        col_1_label = "Token",
        col_2_label = "Abbreviation",
        col_1 = mapreduce(s -> length(string(s)), max, __TOKENS__, init =  length(col_1_label) ) + 2,
        col_2 = mapreduce(s -> length(string(s)), max, __SHORTNAMES__, init = length(col_2_label)) + 2
        println(buffer, "| ", rpad(col_1_label, col_1), " | ", rpad(col_2_label, col_2), " |")
        println(buffer, "|:", rpad("-", col_1, "-"),    " | ", rpad("-", col_2, "-"),    ":|")
        for (long, short) in zip(__TOKENS__, __SHORTNAMES__)
            println(buffer, "| ", rpad("`$long`", col_1), " | ", rpad("`$short`", col_2), " |")
        end
        Highlights.takebuf_str(buffer)
    end

end
