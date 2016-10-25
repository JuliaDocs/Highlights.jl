print_all(Lexers.MatlabLexer, "matlab")

tokentest(
    Lexers.MatlabLexer,
    "% A single line comment.",
    COMMENT_SINGLE => "% A single line comment.",
)

tokentest(
    Lexers.MatlabLexer,
    "%{\n...\n...\n%}",
    COMMENT_MULTILINE => "%{\n...\n...\n%}",
)

tokentest(
    Lexers.MatlabLexer,
    "x = 1;",
    NAME => "x",
    TEXT => " ",
    PUNCTUATION => "=",
    TEXT => " ",
    NUMBER_INTEGER => "1",
    PUNCTUATION => ";",
)

tokentest(
    Lexers.MatlabLexer,
    "function result = func(x, y)",
    KEYWORD => "function",
    WHITESPACE => " ",
    TEXT => "result ",
    PUNCTUATION => "=",
    WHITESPACE => " ",
    NAME_FUNCTION => "func",
    PUNCTUATION => "(",
    TEXT => "x, y",
    PUNCTUATION => ")",
)

tokentest(
    Lexers.MatlabLexer,
    "!ping julialang.org",
    STRING_OTHER => "!ping julialang.org",
)

tokentest(
    Lexers.MatlabLexer,
    "[X, Y] = func(1.0, 2.3e-9, 3j);",
    PUNCTUATION => "[",
    NAME => "X",
    PUNCTUATION => ",",
    TEXT => " ",
    NAME => "Y",
    PUNCTUATION => "]",
    TEXT => " ",
    PUNCTUATION => "=",
    TEXT => " ",
    NAME_FUNCTION => "func",
    PUNCTUATION => "(",
    NUMBER_FLOAT => "1.0",
    PUNCTUATION => ",",
    TEXT => " ",
    NUMBER_FLOAT => "2.3e-9",
    PUNCTUATION => ",",
    TEXT => " ",
    NUMBER_INTEGER => "3",
    NAME => "j",
    PUNCTUATION => ");",
)

tokentest(
    Lexers.MatlabLexer,
    "if x == y",
    KEYWORD => "if",
    TEXT => " ",
    NAME => "x",
    TEXT => " ",
    OPERATOR => "==",
    TEXT => " ",
    NAME => "y",
)

tokentest(
    Lexers.MatlabLexer,
    "'abc ... xyz'",
    STRING => "'abc ... xyz'",
)

tokentest(
    Lexers.MatlabLexer,
    "A(i) = i^2",
    NAME_FUNCTION => "A",
    PUNCTUATION => "(",
    NAME => "i",
    PUNCTUATION => ")",
    TEXT => " ",
    PUNCTUATION => "=",
    TEXT => " ",
    NAME => "i",
    OPERATOR => "^",
    NUMBER_INTEGER => "2",
)

tokentest(
    Lexers.MatlabLexer,
    "x_1 < y_2",
    NAME => "x_1",
    TEXT => " ",
    OPERATOR => "<",
    TEXT => " ",
    NAME => "y_2",
)
