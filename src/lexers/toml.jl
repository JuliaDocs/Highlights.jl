@lexer TOMLLexer Dict(
    :name => "TOML",
    :description => "A lexer for TOML, a simple language for config files.",
    :aliases => ["TOML", "toml"],
    :filenames => ["*.toml"],
    :tokens => Dict(
        :root => [
            (r"\s+"sm, TEXT),
            (r"#.*?$"m, COMMENT),

            (r"\"\"\"", STRING, :triple_strings),
            (r"\"", STRING, :strings),
            (r"'''", STRING, :triple_literal_strings),
            (r"'", STRING, :literal_strings),

            (r"(true|false)$"m, KEYWORD_CONSTANT),
            (r"[a-zA-Z_][a-zA-Z0-9_\-]*", NAME),

            (r"([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(?:\.[0-9]+)?(?:Z|[-+][0-9]{2}:[0-9]{2}|))", LITERAL_DATE),
            (r"([0-9]{4}-[0-9]{2}-[0-9]{2})", LITERAL_DATE),

            (r"([-+]?(?:[0-9_]+(?:\.[0-9_]+)?[eE][-+]?[0-9_]+|[0-9_]*\.[0-9_]+))", NUMBER_FLOAT),

            (r"([-+]?[0-9_]+)", NUMBER_INTEGER),

            (r"[\[\];.,:(){}]", PUNCTUATION),
            (r"\.", PUNCTUATION),

            (r"=", OPERATOR),
        ],
        :strings => [
            (r"\"", STRING, :__pop__),
            (r"\\([\\\"\'\$nrbtfav]|(x|u|U)[a-fA-F0-9]+|\d+)", STRING_ESCAPE),
            (r"."sm, STRING),
        ],
        :triple_strings => [
            (r"\"\"\"", STRING, :__pop__),
            (r"\\([\\\"\'\$nrbtfav]|(x|u|U)[a-fA-F0-9]+|\d+)", STRING_ESCAPE),
            (r"."sm, STRING),
        ],
        :literal_strings => [
            (r"'", STRING, :__pop__),
            (r"."sm, STRING),
        ],
        :triple_literal_strings => [
            (r"'''", STRING, :__pop__),
            (r"."sm, STRING),
        ],
    )
)
