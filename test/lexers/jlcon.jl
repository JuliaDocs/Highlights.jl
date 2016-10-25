print_all(Lexers.JuliaLexer, "jlcon")

tokentest(
    Lexers.JuliaConsoleLexer,
    "julia> x = 2\n2",
    NUMBER => "julia> ",
    NAME => "x",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    NUMBER_INTEGER => "2",
    TEXT => "\n2",
)

tokentest(
    Lexers.JuliaConsoleLexer,
    "julia> x\n2\n\nhelp?> sin\n...",
    NUMBER => "julia> ",
    NAME => "x",
    TEXT => "\n2\n\n",
    NUMBER => "help?> ",
    NAME => "sin",
    TEXT => "\n...",
)

tokentest(
    Lexers.JuliaConsoleLexer,
    """
    julia> f(x) = x + 2
    f

    julia> a = f(1)


           b = f(2)
           a + b
    7
    """,
    NUMBER => "julia> ",
    NAME_FUNCTION => "f",
    PUNCTUATION => "(",
    NAME => "x",
    PUNCTUATION => ")",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    NAME => "x",
    TEXT => " ",
    OPERATOR => "+",
    TEXT => " ",
    NUMBER_INTEGER => "2",
    TEXT => "\nf\n\n",
    NUMBER => "julia> ",
    NAME => "a",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    NAME_FUNCTION => "f",
    PUNCTUATION => "(",
    NUMBER_INTEGER => "1",
    PUNCTUATION => ")",
    TEXT => "\n\n\n       ",
    NAME => "b",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    NAME_FUNCTION => "f",
    PUNCTUATION => "(",
    NUMBER_INTEGER => "2",
    PUNCTUATION => ")",
    TEXT => "\n       ",
    NAME => "a",
    TEXT => " ",
    OPERATOR => "+",
    TEXT => " ",
    NAME => "b",
    TEXT => "\n7\n",
)
