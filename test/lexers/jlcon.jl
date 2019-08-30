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
    julia> A = [4. 3.; 6. 3.]
    2×2 Array{Float64,2}:
     4.0  3.0
     6.0  3.0

    julia> function f(x)
                x + 1
           end
           f(x)

           b = f(0.0)
    1.0
    """,
    NUMBER => "julia> ",
    NAME => "A",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    PUNCTUATION => "[",
    NUMBER_FLOAT => "4.",
    TEXT => " ",
    NUMBER_FLOAT => "3.",
    PUNCTUATION => ";",
    TEXT => " ",
    NUMBER_FLOAT => "6.",
    TEXT => " ",
    NUMBER_FLOAT => "3.",
    PUNCTUATION => "]",
    TEXT => "\n2×2 Array{Float64,2}:\n 4.0  3.0\n 6.0  3.0\n\n",
    NUMBER => "julia> ",
    KEYWORD => "function",
    TEXT => " ",
    NAME_FUNCTION => "f",
    PUNCTUATION => "(",
    NAME => "x",
    PUNCTUATION => ")",
    TEXT => "\n            ",
    NAME => "x",
    TEXT => " ",
    OPERATOR => "+",
    TEXT => " ",
    NUMBER_INTEGER => "1",
    TEXT => "\n       ",
    KEYWORD => "end",
    TEXT => "\n       ",
    NAME_FUNCTION => "f",
    PUNCTUATION => "(",
    NAME => "x",
    PUNCTUATION => ")",
    TEXT => "\n\n       ",
    NAME => "b",
    TEXT => " ",
    OPERATOR => "=",
    TEXT => " ",
    NAME_FUNCTION => "f",
    PUNCTUATION => "(",
    NUMBER_FLOAT => "0.0",
    PUNCTUATION => ")",
    TEXT => "\n1.0\n",
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

tokentest(
    Lexers.JuliaConsoleLexer,
    """
    julia> @show β
    β = 10""",
    NUMBER => "julia> ",
    NAME_DECORATOR => "@show",
    TEXT => " ",
    NAME => "β",
    TEXT => "\nβ = 10",
)
