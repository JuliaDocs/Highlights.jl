print_all(Lexers.JuliaLexer, "julia")

tokentest(
    Lexers.JuliaLexer,
    "#= ... =#",
    COMMENT_MULTILINE => "#= ... =#",
)

tokentest(
    Lexers.JuliaLexer,
    """
    #= ...
       #= ... =#
    =#
    """,
    COMMENT_MULTILINE => "#= ...\n   #= ... =#\n=#",
    TEXT => "\n",
)

tokentest(
    Lexers.JuliaLexer,
    "# ...",
    COMMENT_SINGLE => "# ...",
)

tokentest(
    Lexers.JuliaLexer,
    "   # ...",
    TEXT => "   ",
    COMMENT_SINGLE => "# ...",
)

tokentest(
    Lexers.JuliaLexer,
    "[1]",
    PUNCTUATION => "[",
    NUMBER_INTEGER => "1",
    PUNCTUATION => "]",
)

tokentest(
    Lexers.JuliaLexer,
    "a[begin]",
    NAME => "a",
    PUNCTUATION => "[",
    KEYWORD => "begin",
    PUNCTUATION => "]",
)

tokentest(
    Lexers.JuliaLexer,
    "a[begin:end]",
    NAME => "a",
    PUNCTUATION => "[",
    KEYWORD => "begin",
    OPERATOR => ":",
    KEYWORD => "end",
    PUNCTUATION => "]",
)

tokentest(
    Lexers.JuliaLexer,
    "a[begin-1]",
    NAME => "a",
    PUNCTUATION => "[",
    KEYWORD => "begin",
    OPERATOR => "-",
    NUMBER_INTEGER => "1",
    PUNCTUATION => "]",
)

tokentest(
    Lexers.JuliaLexer,
    "(1,2.0)",
    PUNCTUATION => "(",
    NUMBER_INTEGER => "1",
    PUNCTUATION => ",",
    NUMBER_FLOAT => "2.0",
    PUNCTUATION => ")",
)

tokentest(
    Lexers.JuliaLexer,
    "1 .+ 2 // 3 × !1",
    NUMBER_INTEGER => "1",
    TEXT => " ",
    OPERATOR => ".+",
    TEXT => " ",
    NUMBER_INTEGER => "2",
    TEXT => " ",
    OPERATOR => "//",
    TEXT => " ",
    NUMBER_INTEGER => "3",
    TEXT => " ",
    OPERATOR => "×",
    TEXT => " ",
    OPERATOR => "!",
    NUMBER_INTEGER => "1",
)

tokentest(
    Lexers.JuliaLexer,
    ":symbol",
    STRING_CHAR => ":symbol",
)

tokentest(
    Lexers.JuliaLexer,
    " :symbol",
    TEXT => " ",
    STRING_CHAR => ":symbol",
)

tokentest(
    Lexers.JuliaLexer,
    "(:symbol,",
    PUNCTUATION => "(",
    STRING_CHAR => ":symbol",
    PUNCTUATION => ",",
)

tokentest(
    Lexers.JuliaLexer,
    ":type",
    STRING_CHAR => ":type",
)

tokentest(
    Lexers.JuliaLexer,
    "[:_1, :2]",
    PUNCTUATION => "[",
    STRING_CHAR => ":_1",
    PUNCTUATION => ",",
    TEXT => " ",
    OPERATOR => ":",
    NUMBER_INTEGER => "2",
    PUNCTUATION => "]",
)

tokentest(
    Lexers.JuliaLexer,
    "if x in y",
    KEYWORD => "if",
    TEXT => " ",
    NAME => "x",
    TEXT => " ",
    KEYWORD_PSEUDO => "in",
    TEXT => " ",
    NAME => "y",
)

tokentest(
    Lexers.JuliaLexer,
    "x in y ? false : true",
    NAME => "x",
    TEXT => " ",
    KEYWORD_PSEUDO => "in",
    TEXT => " ",
    NAME => "y",
    TEXT => " ",
    OPERATOR => "?",
    TEXT => " ",
    KEYWORD_CONSTANT => "false",
    TEXT => " ",
    OPERATOR => ":",
    TEXT => " ",
    KEYWORD_CONSTANT => "true",
)

tokentest(
    Lexers.JuliaLexer,
    "let x = 1; 2x end",
    KEYWORD => "let",
    TEXT => " ",
    NAME => "x",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    NUMBER_INTEGER => "1",
    PUNCTUATION => ";",
    TEXT => " ",
    NUMBER_INTEGER => "2",
    NAME => "x",
    TEXT => " ",
    KEYWORD => "end",
)

tokentest(
    Lexers.JuliaLexer,
    "local t; global s; const c",
    KEYWORD_DECLARATION => "local",
    TEXT => " ",
    NAME => "t",
    PUNCTUATION => ";",
    TEXT => " ",
    KEYWORD_DECLARATION => "global",
    TEXT => " ",
    NAME => "s",
    PUNCTUATION => ";",
    TEXT => " ",
    KEYWORD_DECLARATION => "const",
    TEXT => " ",
    NAME => "c",
)

tokentest(
    Lexers.JuliaLexer,
    "module M end",
    KEYWORD => "module",
    TEXT => " ",
    NAME => "M",
    TEXT => " ",
    KEYWORD => "end",
)

tokentest(
    Lexers.JuliaLexer,
    "baremodule M end",
    KEYWORD => "baremodule",
    TEXT => " ",
    NAME => "M",
    TEXT => " ",
    KEYWORD => "end",
)

tokentest(
    Lexers.JuliaLexer,
    "abstract type A <: T end",
    KEYWORD => "abstract type",
    TEXT => " ",
    NAME => "A",
    TEXT => " ",
    OPERATOR => "<:",
    TEXT => " ",
    NAME => "T",
    TEXT => " ",
    KEYWORD => "end"
)

tokentest(
    Lexers.JuliaLexer,
    "mutable struct Point{T}\n    x::T\nend",
    KEYWORD => "mutable struct",
    TEXT => " ",
    NAME_FUNCTION => "Point",
    PUNCTUATION => "{",
    NAME => "T",
    PUNCTUATION => "}",
    TEXT => "\n    ",
    NAME => "x",
    OPERATOR => "::",
    NAME => "T",
    TEXT => "\n",
    KEYWORD => "end",
)

tokentest(
    Lexers.JuliaLexer,
    "Base.@inline f(x) = 2x",
    NAME => "Base",
    OPERATOR => ".",
    NAME_DECORATOR => "@inline",
    TEXT => " ",
    NAME_FUNCTION => "f",
    PUNCTUATION => "(",
    NAME => "x",
    PUNCTUATION => ")",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    NUMBER_INTEGER => "2",
    NAME => "x",
)

tokentest(
    Lexers.JuliaLexer,
    "struct Empty{T} end",
    KEYWORD => "struct",
    TEXT => " ",
    NAME_FUNCTION => "Empty",
    PUNCTUATION => "{",
    NAME => "T",
    PUNCTUATION => "}",
    TEXT => " ",
    KEYWORD => "end",
)

tokentest(
    Lexers.JuliaLexer,
    "struct Empty{T} where T <: S end",
    KEYWORD => "struct",
    TEXT => " ",
    NAME_FUNCTION => "Empty",
    PUNCTUATION => "{",
    NAME => "T",
    PUNCTUATION => "}",
    TEXT => " ",
    KEYWORD_PSEUDO => "where",
    TEXT => " ",
    NAME => "T",
    TEXT => " ",
    OPERATOR => "<:",
    TEXT => " ",
    NAME => "S",
    TEXT => " ",
    KEYWORD => "end",
)

tokentest(
    Lexers.JuliaLexer,
    "primitive type Float16 <: AbstractFloat 16 end",
    KEYWORD => "primitive type",
    TEXT => " ",
    NAME => "Float16",
    TEXT => " ",
    OPERATOR => "<:",
    TEXT => " ",
    NAME => "AbstractFloat",
    TEXT => " ",
    NUMBER_INTEGER => "16",
    TEXT => " ",
    KEYWORD => "end",
)

tokentest(
    Lexers.JuliaLexer,
    """
    macro something(x...)
        # ...
    end
    """,
    KEYWORD => "macro",
    TEXT => " ",
    NAME_FUNCTION => "something",
    PUNCTUATION => "(",
    NAME => "x",
    OPERATOR => "...",
    PUNCTUATION => ")",
    TEXT => "\n    ",
    COMMENT_SINGLE => "# ...",
    TEXT => "\n",
    KEYWORD => "end",
    TEXT => "\n",
)

tokentest(
    Lexers.JuliaLexer,
    "' ', '\\n', '\\'', '\"', '\\u1234', '⻆'",
    STRING_CHAR => "' '",
    PUNCTUATION => ",",
    TEXT => " ",
    STRING_CHAR => "'\\n'",
    PUNCTUATION => ",",
    TEXT => " ",
    STRING_CHAR => "'\\''",
    PUNCTUATION => ",",
    TEXT => " ",
    STRING_CHAR => "'\"'",
    PUNCTUATION => ",",
    TEXT => " ",
    STRING_CHAR => "'\\u1234'",
    PUNCTUATION => ",",
    TEXT => " ",
    STRING_CHAR => "'⻆'",
)

tokentest(
    Lexers.JuliaLexer,
    """
    "\\\"\\\" ..."
    """,
    STRING => "\"",
    STRING_ESCAPE => "\\\"\\\"",
    STRING => " ...\"",
    TEXT => "\n",
)

tokentest(
    Lexers.JuliaLexer,
    """
    " \$x \$(let x = y + 1; x^2; end)..."
    """,
    STRING => "\" ",
    STRING_INTERPOL => "\$x",
    STRING => " ",
    STRING_INTERPOL => "\$",
    PUNCTUATION => "(",
    KEYWORD => "let",
    TEXT => " ",
    NAME => "x",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    NAME => "y",
    TEXT => " ",
    OPERATOR => "+",
    TEXT => " ",
    NUMBER_INTEGER => "1",
    PUNCTUATION => ";",
    TEXT => " ",
    NAME => "x",
    OPERATOR => "^",
    NUMBER_INTEGER => "2",
    PUNCTUATION => ";",
    TEXT => " ",
    KEYWORD => "end",
    PUNCTUATION => ")",
    STRING => "...\"",
    TEXT => "\n",
)

tokentest(
    Lexers.JuliaLexer,
    """r"[a-z]+\$xyz"m""",
    STRING_OTHER => "r\"[a-z]+\$xyz\"",
    NAME => "m",
)

tokentest(
    Lexers.JuliaLexer,
    "run(`foo \$(bar)`)",
    NAME_FUNCTION => "run",
    PUNCTUATION => "(",
    STRING_BACKTICK => "`foo ",
    STRING_INTERPOL => "\$",
    PUNCTUATION => "(",
    NAME => "bar",
    PUNCTUATION => ")",
    STRING_BACKTICK => "`",
    PUNCTUATION => ")",
)

tokentest(
    Lexers.JuliaLexer,
    """
    "\\\\"
    """,
    STRING => "\"",
    STRING_ESCAPE => "\\\\",
    STRING => "\"",
    TEXT => "\n",
)

tokentest(
    Lexers.JuliaLexer,
    """
    1_000_000_000 + 1.0e-9 * .121 / 1121.
    1f0 - 1E-12
    0b100_101_111
    0o12123535252
    0x4312afAfabC
    1234
    1_2_3_4
    """,
    NUMBER_INTEGER => "1_000_000_000",
    TEXT => " ",
    OPERATOR => "+",
    TEXT => " ",
    NUMBER_FLOAT => "1.0e-9",
    TEXT => " ",
    OPERATOR => "*",
    TEXT => " ",
    NUMBER_FLOAT => ".121",
    TEXT => " ",
    OPERATOR => "/",
    TEXT => " ",
    NUMBER_FLOAT => "1121.",
    TEXT => "\n",
    NUMBER_FLOAT => "1f0",
    TEXT => " ",
    OPERATOR => "-",
    TEXT => " ",
    NUMBER_FLOAT => "1E-12",
    TEXT => "\n",
    NUMBER_BIN => "0b100_101_111",
    TEXT => "\n",
    NUMBER_OCT => "0o12123535252",
    TEXT => "\n",
    NUMBER_HEX => "0x4312afAfabC",
    TEXT => "\n",
    NUMBER_INTEGER => "1234",
    TEXT => "\n",
    NUMBER_INTEGER => "1_2_3_4",
    TEXT => "\n",
)

tokentest(
    Lexers.JuliaLexer,
    "√",
    OPERATOR => "√",
)

tokentest(
    Lexers.JuliaLexer,
    "√α",
    OPERATOR => "√",
    NAME => "α",
)
