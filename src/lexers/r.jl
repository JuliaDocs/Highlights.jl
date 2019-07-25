@lexer RLexer let
    keywords = [
        "if", "else", "for", "while", "repeat", "in", "next", "break", "return", "switch",
        "function"
    ]
    types = [
        "array", "category", "character", "complex", "double", "function", "integer",
        "list", "logical", "matrix", "numeric", "vector", "data.frame", "c"
    ]
    builtin_symbols = [
        "NULL", "NA(_(integer|real|complex|character)_)?", "letters", "LETTERS", "Inf",
        "TRUE", "FALSE", "NaN", "pi", "\\.\\.(\\.|[0-9]+)"
    ]
    Dict(
        :name => "R",
        :description => "A lexer for the R language for statistical computing.",
        :aliases => ["r", "rlang"],
        :filenames => ["*.r"],
        :comments => "Based on the Pygments lexer.",
        :tokens => Dict(
            :comments => [
                (r"#.*$"m, COMMENT_SINGLE),
            ],
            :valid_name => [
                (r"[a-zA-Z][\w.]*", NAME),
                (r"\.[a-zA-Z_][\w.]*", NAME),
            ],
            :punctuation => [
                (r"(\[{1,2}|\]{1,2}|\(|\)|;|,)", PUNCTUATION),
            ],
            :keywords => [
                (words(keywords; suffix = "\\b(?![\\w.])"), KEYWORD_RESERVED),
                (words(types; suffix = "\\b(?![\\w.])"), KEYWORD_TYPE),
                (r"(library|require|attach|detach|source)\b(?![\\w.])", KEYWORD_NAMESPACE),
            ],
            :operators => [
                (r"(<<?-|->>?|-|==|<=|>=|<|>|&&?|!=|\|\|?|\?)", OPERATOR),
                (r"(\*|\+|\^|/|!|%[^%]*%|=|~|\$|@|:{1,3})", OPERATOR)
            ],
            :builtin_symbols => [
                (words(builtin_symbols; suffix = "(?![\\w.])"), KEYWORD_CONSTANT),
                (r"(T|F)\b", NAME_BUILTIN_PSEUDO),
            ],
            :numbers => [
                (r"0[xX][a-fA-F0-9]+([pP][0-9]+)?[Li]?", NUMBER_HEX),
                (r"[+-]?([0-9]+(\.[0-9]+)?|\.[0-9]+|\.)([eE][+-]?[0-9]+)?[Li]?", NUMBER),
            ],
            :statements => [
                :comments,
                # whitespaces
                (r"\s+", TEXT),
                (r"`.*?`", STRING_BACKTICK),
                (r"'", STRING, :string_squote),
                (r"\"", STRING, :string_dquote),
                :builtin_symbols,
                :numbers,
                :keywords,
                :valid_name,
                :operators,
                :punctuation,
            ],
            :root => [
                :statements,
                (r"\{|\}", PUNCTUATION),
                (r".", TEXT),
            ],
            :string_squote => [
                (r"([^'\\]|\\.)*'", STRING, :__pop__),
            ],
            :string_dquote => [
                (r"([^\"\\]|\\.)*\"", STRING, :__pop__),
            ],
        ),
    )
end
