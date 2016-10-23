print_all(Lexers.JuliaLexer, "julia")

tokentest(
    Lexers.JuliaLexer,
    "#= ... =#",
    :comment_multiline => "#= ... =#",
)

tokentest(
    Lexers.JuliaLexer,
    """
    #= ...
       #= ... =#
    =#
    """,
    :comment_multiline => "#= ...\n   #= ... =#\n=#",
    :text => "\n",
)

tokentest(
    Lexers.JuliaLexer,
    "# ...",
    :comment_singleline => "# ...",
)

tokentest(
    Lexers.JuliaLexer,
    "   # ...",
    :text => "   ",
    :comment_singleline => "# ...",
)

tokentest(
    Lexers.JuliaLexer,
    "[1]",
    :punctuation => "[",
    :number_integer => "1",
    :punctuation => "]",
)

tokentest(
    Lexers.JuliaLexer,
    "(1,2.0)",
    :punctuation => "(",
    :number_integer => "1",
    :punctuation => ",",
    :number_float => "2.0",
    :punctuation => ")",
)

tokentest(
    Lexers.JuliaLexer,
    "if x in y",
    :keyword => "if",
    :text => " ",
    :name => "x",
    :text => " ",
    :keyword_pseudo => "in",
    :text => " ",
    :name => "y",
)

tokentest(
    Lexers.JuliaLexer,
    "x in y ? false : true",
    :name => "x",
    :text => " ",
    :keyword_pseudo => "in",
    :text => " ",
    :name => "y",
    :text => " ",
    :operator => "?",
    :text => " ",
    :keyword_constant => "false",
    :text => " ",
    :operator => ":",
    :text => " ",
    :keyword_constant => "true",
)

tokentest(
    Lexers.JuliaLexer,
    "let x = 1; 2x end",
    :keyword => "let",
    :text => " ",
    :name => "x",
    :text => " ",
    :operator => "=",
    :text => " ",
    :number_integer => "1",
    :punctuation => ";",
    :text => " ",
    :number_integer => "2",
    :name => "x",
    :text => " ",
    :keyword_end => "end",
)

tokentest(
    Lexers.JuliaLexer,
    "local t; global s; const c",
    :keyword_declaration => "local",
    :text => " ",
    :name => "t",
    :punctuation => ";",
    :text => " ",
    :keyword_declaration => "global",
    :text => " ",
    :name => "s",
    :punctuation => ";",
    :text => " ",
    :keyword_declaration => "const",
    :text => " ",
    :name => "c",
)


tokentest(
    Lexers.JuliaLexer,
    "module M end",
    :keyword => "module",
    :text => " ",
    :name => "M",
    :text => " ",
    :keyword_end => "end",
)

tokentest(
    Lexers.JuliaLexer,
    "baremodule M end",
    :keyword => "baremodule",
    :text => " ",
    :name => "M",
    :text => " ",
    :keyword_end => "end",
)

tokentest(
    Lexers.JuliaLexer,
    "typealias T A",
    :keyword => "typealias",
    :text => " ",
    :name => "T",
    :text => " ",
    :name => "A",
)

tokentest(
    Lexers.JuliaLexer,
    "abstract A <: T",
    :keyword => "abstract",
    :text => " ",
    :name => "A",
    :text => " ",
    :operator => "<:",
    :text => " ",
    :name => "T",
)

tokentest(
    Lexers.JuliaLexer,
    "type Point{T}\n    x::T\nend",
    :keyword => "type",
    :text => " ",
    :name_function => "Point",
    :punctuation => "{",
    :name => "T",
    :punctuation => "}",
    :text => "\n    ",
    :name => "x",
    :operator => "::",
    :name => "T",
    :text => "\n",
    :keyword_end => "end",
)

tokentest(
    Lexers.JuliaLexer,
    "Base.@inline f(x) = 2x",
    :name => "Base",
    :operator => ".",
    :name_decorator => "@inline",
    :text => " ",
    :name_function => "f",
    :punctuation => "(",
    :name => "x",
    :punctuation => ")",
    :text => " ",
    :operator => "=",
    :text => " ",
    :number_integer => "2",
    :name => "x",
)

tokentest(
    Lexers.JuliaLexer,
    "immutable Empty{T} end",
    :keyword => "immutable",
    :text => " ",
    :name_function => "Empty",
    :punctuation => "{",
    :name => "T",
    :punctuation => "}",
    :text => " ",
    :keyword_end => "end",
)

tokentest(
    Lexers.JuliaLexer,
    """
    macro something(x...)
        # ...
    end
    """,
    :keyword => "macro",
    :text => " ",
    :name_function => "something",
    :punctuation => "(",
    :name => "x",
    :operator => "...",
    :punctuation => ")",
    :text => "\n    ",
    :comment_singleline => "# ...",
    :text => "\n",
    :keyword_end => "end",
    :text => "\n",
)

tokentest(
    Lexers.JuliaLexer,
    "' ', '\\n', '\\'', '\"', '\\u1234', '⻆'",
    :string_char => "' '",
    :punctuation => ",",
    :text => " ",
    :string_char => "'\\n'",
    :punctuation => ",",
    :text => " ",
    :string_char => "'\\''",
    :punctuation => ",",
    :text => " ",
    :string_char => "'\"'",
    :punctuation => ",",
    :text => " ",
    :string_char => "'\\u1234'",
    :punctuation => ",",
    :text => " ",
    :string_char => "'⻆'",
)

tokentest(
    Lexers.JuliaLexer,
    """
    "\\\"\\\" ..."
    """,
    :string => "\"",
    :string_escape => "\\\"\\\"",
    :string => " ...\"",
    :text => "\n",
)

tokentest(
    Lexers.JuliaLexer,
    """
    " \$x \$(let x = y + 1; x^2; end)..."
    """,
    :string => "\" ",
    :string_iterpol => "\$x",
    :string => " ",
    :string_iterpol => "\$",
    :punctuation => "(",
    :keyword => "let",
    :text => " ",
    :name => "x",
    :text => " ",
    :operator => "=",
    :text => " ",
    :name => "y",
    :text => " ",
    :operator => "+",
    :text => " ",
    :number_integer => "1",
    :punctuation => ";",
    :text => " ",
    :name => "x",
    :operator => "^",
    :number_integer => "2",
    :punctuation => ";",
    :text => " ",
    :keyword_end => "end",
    :punctuation => ")",
    :string => "...\"",
    :text => "\n",
)

tokentest(
    Lexers.JuliaLexer,
    """r"[a-z]+\$xyz"m""",
    :string_macro => "r\"[a-z]+\$xyz\"",
    :name => "m",
)

tokentest(
    Lexers.JuliaLexer,
    "run(`foo \$(bar)`)",
    :name_function => "run",
    :punctuation => "(",
    :string_backtick => "`foo ",
    :string_iterpol => "\$",
    :punctuation => "(",
    :name => "bar",
    :punctuation => ")",
    :string_backtick => "`",
    :punctuation => ")",
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
    :number_integer => "1_000_000_000",
    :text => " ",
    :operator => "+",
    :text => " ",
    :number_float => "1.0e-9",
    :text => " ",
    :operator => "*",
    :text => " ",
    :number_float => ".121",
    :text => " ",
    :operator => "/",
    :text => " ",
    :number_float => "1121.",
    :text => "\n",
    :number_float => "1f0",
    :text => " ",
    :operator => "-",
    :text => " ",
    :number_float => "1E-12",
    :text => "\n",
    :number_bin => "0b100_101_111",
    :text => "\n",
    :number_oct => "0o12123535252",
    :text => "\n",
    :number_hex => "0x4312afAfabC",
    :text => "\n",
    :number_integer => "1234",
    :text => "\n",
    :number_integer => "1_2_3_4",
    :text => "\n",
)
