print_all(Lexers.RLexer, "r")

tokentest(
    Lexers.RLexer,
    "# Comments...",
    COMMENT_SINGLE => "# Comments...",
)

tokentest(
    Lexers.RLexer,
    "   # Comments...",
    TEXT => "   ",
    COMMENT_SINGLE => "# Comments...",
)

tokentest(
    Lexers.RLexer,
    "x <- 1",
    NAME => "x",
    TEXT => " ",
    OPERATOR => "<-",
    TEXT => " ",
    NUMBER => "1",
)

tokentest(
    Lexers.RLexer,
    "func(x, y)",
    NAME => "func",
    PUNCTUATION => "(",
    NAME => "x",
    PUNCTUATION => ",",
    TEXT => " ",
    NAME => "y",
    PUNCTUATION => ")",
)

tokentest(
    Lexers.RLexer,
    "c(1, 2)",
    KEYWORD_TYPE => "c",
    PUNCTUATION => "(",
    NUMBER => "1",
    PUNCTUATION => ",",
    TEXT => " ",
    NUMBER => "2",
    PUNCTUATION => ")",
)

tokentest(
    Lexers.RLexer,
    "-Inf + 1e9",
    OPERATOR => "-",
    KEYWORD_CONSTANT => "Inf",
    TEXT => " ",
    OPERATOR => "+",
    TEXT => " ",
    NUMBER => "1e9",
)

tokentest(
    Lexers.RLexer,
    "61.4e-12 * 1.2e2",
    NUMBER => "61.4e-12",
    TEXT => " ",
    OPERATOR => "*",
    TEXT => " ",
    NUMBER => "1.2e2",
)

tokentest(
    Lexers.RLexer,
    "4 %% 3",
    NUMBER => "4",
    TEXT => " ",
    OPERATOR => "%%",
    TEXT => " ",
    NUMBER => "3",
)

tokentest(
    Lexers.RLexer,
    "A %*% t(A)",
    NAME => "A",
    TEXT => " ",
    OPERATOR => "%*%",
    TEXT => " ",
    NAME => "t",
    PUNCTUATION => "(",
    NAME => "A",
    PUNCTUATION => ")",
)

tokentest(
    Lexers.RLexer,
    "FALSE && TRUE",
    KEYWORD_CONSTANT => "FALSE",
    TEXT => " ",
    OPERATOR => "&&",
    TEXT => " ",
    KEYWORD_CONSTANT => "TRUE",
)

tokentest(
    Lexers.RLexer,
    "' \" ' \" ' \" ' \\' ' \" \\\" \"",
    STRING => "' \" '",
    TEXT => " ",
    STRING => "\" ' \"",
    TEXT => " ",
    STRING => "' \\' '",
    TEXT => " ",
    STRING => "\" \\\" \"",
)

tokentest(
    Lexers.RLexer,
    "while (TRUE) {",
    KEYWORD_RESERVED => "while",
    TEXT => " ",
    PUNCTUATION => "(",
    KEYWORD_CONSTANT => "TRUE",
    PUNCTUATION => ")",
    TEXT => " ",
    PUNCTUATION => "{",
)

tokentest(
    Lexers.RLexer,
    "for (x in 1:10) {",
    KEYWORD_RESERVED => "for",
    TEXT => " ",
    PUNCTUATION => "(",
    NAME => "x",
    TEXT => " ",
    KEYWORD_RESERVED => "in",
    TEXT => " ",
    NUMBER => "1",
    OPERATOR => ":",
    NUMBER => "10",
    PUNCTUATION => ")",
    TEXT => " ",
    PUNCTUATION => "{",
)
