definition(::Type{TOMLLexer}) = Dict(
    :name => "TOML",
    :description => "A lexer for TOML, a simple language for config files.",
    :aliases => ["TOML", "toml"],
    :filenames => ["*.toml"],
    :tokens => Dict(
        :root => [
            (r"\s+"sm, :text),
            (r"#.*?$"m, :comment),

            (r"\"\"\"", :string, :triple_strings),
            (r"\"", :string, :strings),
            (r"'''", :string, :triple_literal_strings),
            (r"'", :string, :literal_strings),

            (r"(true|false)$"m, :keyword_constant),
            (r"[a-zA-Z_][a-zA-Z0-9_\-]*", :name),

            (r"([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(?:\.[0-9]+)?(?:Z|[-+][0-9]{2}:[0-9]{2}|))", :literal_date),
            (r"([0-9]{4}-[0-9]{2}-[0-9]{2})", :literal_date),

            (r"([-+]?(?:[0-9_]+(?:\.[0-9_]+)?[eE][-+]?[0-9_]+|[0-9_]*\.[0-9_]+))", :number_float),

            (r"([-+]?[0-9_]+)", :number_integer),

            (r"[\[\];.,:(){}]", :punctuation),
            (r"\.", :punctuation),

            (r"=", :operator),
        ],
        :strings => [
            (r"\"", :string, :__pop__),
            (r"\\([\\\"\'\$nrbtfav]|(x|u|U)[a-fA-F0-9]+|\d+)", :string_escape),
            (r"."sm, :string),
        ],
        :triple_strings => [
            (r"\"\"\"", :string, :__pop__),
            (r"\\([\\\"\'\$nrbtfav]|(x|u|U)[a-fA-F0-9]+|\d+)", :string_escape),
            (r"."sm, :string),
        ],
        :literal_strings => [
            (r"'", :string, :__pop__),
            (r"."sm, :string),
        ],
        :triple_literal_strings => [
            (r"'''", :string, :__pop__),
            (r"."sm, :string),
        ],
    )
)
