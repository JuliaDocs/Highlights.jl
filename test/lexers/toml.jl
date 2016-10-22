print_all(Lexers.TOMLLexer, "toml")

tokentest(
    Lexers.TOMLLexer,
    "# Comment",
    :comment => "# Comment",
)

tokentest(
    Lexers.TOMLLexer,
    "x = 1",
    :name => "x",
    :text => " ",
    :operator => "=",
    :text => " ",
    :number_integer => "1",
)

tokentest(
    Lexers.TOMLLexer,
    "[header]",
    :punctuation => "[",
    :name => "header",
    :punctuation => "]",
)

tokentest(
    Lexers.TOMLLexer,
    "name = \"name\"",
    :name => "name",
    :text => " ",
    :operator => "=",
    :text => " ",
    :string => "\"name\"",
)

tokentest(
    Lexers.TOMLLexer,
    "dob = 1979-05-27T07:32:00-08:00",
    :name => "dob",
    :text => " ",
    :operator => "=",
    :text => " ",
    :literal_date => "1979-05-27T07:32:00-08:00",
)

tokentest(
    Lexers.TOMLLexer,
    "ports = [ 8001, 8001, 8002 ]",
    :name => "ports",
    :text => " ",
    :operator => "=",
    :text => " ",
    :punctuation => "[",
    :text => " ",
    :number_integer => "8001",
    :punctuation => ",",
    :text => " ",
    :number_integer => "8001",
    :punctuation => ",",
    :text => " ",
    :number_integer => "8002",
    :text => " ",
    :punctuation => "]",
)

tokentest(
    Lexers.TOMLLexer,
    "enabled = true",
    :name => "enabled",
    :text => " ",
    :operator => "=",
    :text => " ",
    :keyword_constant => "true",
)

tokentest(
    Lexers.TOMLLexer,
    "[a.b]",
    :punctuation => "[",
    :name => "a",
    :punctuation => ".",
    :name => "b",
    :punctuation => "]",
)

tokentest(
    Lexers.TOMLLexer,
    "\"ʎǝʞ\" = \"value\"",
    :string => "\"ʎǝʞ\"",
    :text => " ",
    :operator => "=",
    :text => " ",
    :string => "\"value\"",
)

tokentest(
    Lexers.TOMLLexer,
    "'quoted \"value\"' = \"value\"",
    :string => "'quoted \"value\"'",
    :text => " ",
    :operator => "=",
    :text => " ",
    :string => "\"value\"",
)

tokentest(
    Lexers.TOMLLexer,
    "\" \\n \\t \"",
    :string => "\" ",
    :string_escape => "\\n",
    :string => " ",
    :string_escape => "\\t",
    :string => " \"",
)

tokentest(
    Lexers.TOMLLexer,
    "'<\\i\\c*\\s*>'",
    :string => "'<\\i\\c*\\s*>'",
)

tokentest(
    Lexers.TOMLLexer,
    "+99 42 0 -17 1_000 5_349_221 1_2_3_4_5 +1.0 3.1415 -0.01",
    :number_integer => "+99",
    :text => " ",
    :number_integer => "42",
    :text => " ",
    :number_integer => "0",
    :text => " ",
    :number_integer => "-17",
    :text => " ",
    :number_integer => "1_000",
    :text => " ",
    :number_integer => "5_349_221",
    :text => " ",
    :number_integer => "1_2_3_4_5",
    :text => " ",
    :number_float => "+1.0",
    :text => " ",
    :number_float => "3.1415",
    :text => " ",
    :number_float => "-0.01",
)

tokentest(
    Lexers.TOMLLexer,
    "5e+22 1e6 -2E-2 6.626e-34 9_224_617.445_991_228_313",
    :number_float => "5e+22",
    :text => " ",
    :number_float => "1e6",
    :text => " ",
    :number_float => "-2E-2",
    :text => " ",
    :number_float => "6.626e-34",
    :text => " ",
    :number_float => "9_224_617.445_991_228_313",
)

tokentest(
    Lexers.TOMLLexer,
    "date1 = 1979-05-27T07:32:00Z",
    :name => "date1",
    :text => " ",
    :operator => "=",
    :text => " ",
    :literal_date => "1979-05-27T07:32:00Z",
)

tokentest(
    Lexers.TOMLLexer,
    "date2 = 1979-05-27T00:32:00-07:00",
    :name => "date2",
    :text => " ",
    :operator => "=",
    :text => " ",
    :literal_date => "1979-05-27T00:32:00-07:00",
)

tokentest(
    Lexers.TOMLLexer,
    "date3 = 1979-05-27T00:32:00.999999-07:00",
    :name => "date3",
    :text => " ",
    :operator => "=",
    :text => " ",
    :literal_date => "1979-05-27T00:32:00.999999-07:00",
)

tokentest(
    Lexers.TOMLLexer,
    "1979-05-27T07:32:00",
    :literal_date => "1979-05-27T07:32:00",
)

tokentest(
    Lexers.TOMLLexer,
    "1979-05-27T00:32:00.999999",
    :literal_date => "1979-05-27T00:32:00.999999",
)

tokentest(
    Lexers.TOMLLexer,
    "1979-05-27",
    :literal_date => "1979-05-27",
)

tokentest(
    Lexers.TOMLLexer,
    "point = { x = 1, y = 2 }",
    :name => "point",
    :text => " ",
    :operator => "=",
    :text => " ",
    :punctuation => "{",
    :text => " ",
    :name => "x",
    :text => " ",
    :operator => "=",
    :text => " ",
    :number_integer => "1",
    :punctuation => ",",
    :text => " ",
    :name => "y",
    :text => " ",
    :operator => "=",
    :text => " ",
    :number_integer => "2",
    :text => " ",
    :punctuation => "}",
)
