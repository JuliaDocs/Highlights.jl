print_all(Lexers.FortranLexer, "fortran")

tokentest(
    Lexers.FortranLexer,
    "! a single line comment.",
    COMMENT => "! a single line comment.",
)

tokentest(
    Lexers.FortranLexer,
    "x = 1 ! a single line comment.",
    NAME => "x",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    NUMBER_INTEGER => "1",
    TEXT => " ",
    COMMENT => "! a single line comment.",
)

tokentest(
    Lexers.FortranLexer,
    "program test\n    print *, 'hello world'",
    KEYWORD => "program",
    TEXT => " ",
    NAME => "test",
    TEXT => "\n    ",
    KEYWORD => "print",
    TEXT => " ",
    OPERATOR => "*",
    PUNCTUATION => ",",
    TEXT => " ",
    STRING_SINGLE => "'hello world'",
)

tokentest(
    Lexers.FortranLexer,
    "print \"(F6.3)\", 4.32",
    KEYWORD => "print",
    TEXT => " ",
    STRING_DOUBLE => "\"(F6.3)\"",
    PUNCTUATION => ",",
    TEXT => " ",
    NUMBER_FLOAT => "4.32",
)

tokentest(
    Lexers.FortranLexer,
    "# a preprocessor comment",
    COMMENT_PREPROC => "# a preprocessor comment",
)

tokentest(
    Lexers.FortranLexer,
    ".true. == .FALSE. .and. .false.",
    NAME_BUILTIN => ".true.",
    TEXT => " ",
    OPERATOR => "==",
    TEXT => " ",
    NAME_BUILTIN => ".FALSE.",
    TEXT => " ",
    OPERATOR_WORD => ".and.",
    TEXT => " ",
    NAME_BUILTIN => ".false.",
)

tokentest(
    Lexers.FortranLexer,
    "TYPE string80\n    INTEGER length",
    KEYWORD => "TYPE",
    TEXT => " ",
    NAME => "string80",
    TEXT => "\n    ",
    KEYWORD_TYPE => "INTEGER",
    TEXT => " ",
    NAME => "length",
)

tokentest(
    Lexers.FortranLexer,
    "w = 5/v + a(1:5, 5)",
    NAME => "w",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    NUMBER_INTEGER => "5",
    OPERATOR => "/",
    NAME => "v",
    TEXT => " ",
    OPERATOR => "+",
    TEXT => " ",
    NAME => "a",
    PUNCTUATION => "(",
    NUMBER_INTEGER => "1",
    PUNCTUATION => ":",
    NUMBER_INTEGER => "5",
    PUNCTUATION => ",",
    TEXT => " ",
    NUMBER_INTEGER => "5",
    PUNCTUATION => ")",
)
