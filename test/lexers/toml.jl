print_all(Lexers.TOMLLexer, "toml")

tokentest(
    Lexers.TOMLLexer,
    "# Comment",
    COMMENT => "# Comment",
)

tokentest(
    Lexers.TOMLLexer,
    "x = 1",
    NAME => "x",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    NUMBER_INTEGER => "1",
)

tokentest(
    Lexers.TOMLLexer,
    "[header]",
    PUNCTUATION => "[",
    NAME => "header",
    PUNCTUATION => "]",
)

tokentest(
    Lexers.TOMLLexer,
    "name = \"name\"",
    NAME => "name",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    STRING => "\"name\"",
)

tokentest(
    Lexers.TOMLLexer,
    "dob = 1979-05-27T07:32:00-08:00",
    NAME => "dob",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    LITERAL_DATE => "1979-05-27T07:32:00-08:00",
)

tokentest(
    Lexers.TOMLLexer,
    "ports = [ 8001, 8001, 8002 ]",
    NAME => "ports",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    PUNCTUATION => "[",
    TEXT => " ",
    NUMBER_INTEGER => "8001",
    PUNCTUATION => ",",
    TEXT => " ",
    NUMBER_INTEGER => "8001",
    PUNCTUATION => ",",
    TEXT => " ",
    NUMBER_INTEGER => "8002",
    TEXT => " ",
    PUNCTUATION => "]",
)

tokentest(
    Lexers.TOMLLexer,
    "enabled = true",
    NAME => "enabled",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    KEYWORD_CONSTANT => "true",
)

tokentest(
    Lexers.TOMLLexer,
    "[a.b]",
    PUNCTUATION => "[",
    NAME => "a",
    PUNCTUATION => ".",
    NAME => "b",
    PUNCTUATION => "]",
)

tokentest(
    Lexers.TOMLLexer,
    "\"ʎǝʞ\" = \"value\"",
    STRING => "\"ʎǝʞ\"",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    STRING => "\"value\"",
)

tokentest(
    Lexers.TOMLLexer,
    "'quoted \"value\"' = \"value\"",
    STRING => "'quoted \"value\"'",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    STRING => "\"value\"",
)

tokentest(
    Lexers.TOMLLexer,
    "\" \\n \\t \"",
    STRING => "\" ",
    STRING_ESCAPE => "\\n",
    STRING => " ",
    STRING_ESCAPE => "\\t",
    STRING => " \"",
)

tokentest(
    Lexers.TOMLLexer,
    "'<\\i\\c*\\s*>'",
    STRING => "'<\\i\\c*\\s*>'",
)

tokentest(
    Lexers.TOMLLexer,
    "+99 42 0 -17 1_000 5_349_221 1_2_3_4_5 +1.0 3.1415 -0.01",
    NUMBER_INTEGER => "+99",
    TEXT => " ",
    NUMBER_INTEGER => "42",
    TEXT => " ",
    NUMBER_INTEGER => "0",
    TEXT => " ",
    NUMBER_INTEGER => "-17",
    TEXT => " ",
    NUMBER_INTEGER => "1_000",
    TEXT => " ",
    NUMBER_INTEGER => "5_349_221",
    TEXT => " ",
    NUMBER_INTEGER => "1_2_3_4_5",
    TEXT => " ",
    NUMBER_FLOAT => "+1.0",
    TEXT => " ",
    NUMBER_FLOAT => "3.1415",
    TEXT => " ",
    NUMBER_FLOAT => "-0.01",
)

tokentest(
    Lexers.TOMLLexer,
    "5e+22 1e6 -2E-2 6.626e-34 9_224_617.445_991_228_313",
    NUMBER_FLOAT => "5e+22",
    TEXT => " ",
    NUMBER_FLOAT => "1e6",
    TEXT => " ",
    NUMBER_FLOAT => "-2E-2",
    TEXT => " ",
    NUMBER_FLOAT => "6.626e-34",
    TEXT => " ",
    NUMBER_FLOAT => "9_224_617.445_991_228_313",
)

tokentest(
    Lexers.TOMLLexer,
    "date1 = 1979-05-27T07:32:00Z",
    NAME => "date1",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    LITERAL_DATE => "1979-05-27T07:32:00Z",
)

tokentest(
    Lexers.TOMLLexer,
    "date2 = 1979-05-27T00:32:00-07:00",
    NAME => "date2",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    LITERAL_DATE => "1979-05-27T00:32:00-07:00",
)

tokentest(
    Lexers.TOMLLexer,
    "date3 = 1979-05-27T00:32:00.999999-07:00",
    NAME => "date3",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    LITERAL_DATE => "1979-05-27T00:32:00.999999-07:00",
)

tokentest(
    Lexers.TOMLLexer,
    "1979-05-27T07:32:00",
    LITERAL_DATE => "1979-05-27T07:32:00",
)

tokentest(
    Lexers.TOMLLexer,
    "1979-05-27T00:32:00.999999",
    LITERAL_DATE => "1979-05-27T00:32:00.999999",
)

tokentest(
    Lexers.TOMLLexer,
    "1979-05-27",
    LITERAL_DATE => "1979-05-27",
)

tokentest(
    Lexers.TOMLLexer,
    "point = { x = 1, y = 2 }",
    NAME => "point",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    PUNCTUATION => "{",
    TEXT => " ",
    NAME => "x",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    NUMBER_INTEGER => "1",
    PUNCTUATION => ",",
    TEXT => " ",
    NAME => "y",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    NUMBER_INTEGER => "2",
    TEXT => " ",
    PUNCTUATION => "}",
)
