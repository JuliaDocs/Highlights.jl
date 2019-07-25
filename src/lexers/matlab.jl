@lexer MatlabLexer let
    keywords = [
        "break", "case", "catch", "classdef", "continue", "else", "elseif",
        "end", "enumerated", "events", "for", "function", "global", "if",
        "methods", "otherwise", "parfor", "persistent", "properties",
        "return", "spmd", "switch", "try", "while",
    ]
    Dict(
        :name => "Matlab",
        :description => "A lexer for Matlab source files.",
        :comments => "Based on the lexer from Pygments.",
        :aliases => ["matlab"],
        :tokens => Dict(
            :root => [
                (r"^!.*"m, STRING_OTHER),
                (r"%\{\s*$"ms, COMMENT_MULTILINE, :blockcomment),
                (r"%.*$"m, COMMENT_SINGLE),
                (r"^\s*function", KEYWORD, :deffunc),

                (words(keywords, suffix = "\\b"), KEYWORD),

                (r"\.\.\..*$"m, COMMENT),

                (r"(-|==|~=|<|>|<=|>=|&&|&|~|\|\|?|\^)", OPERATOR),
                (r"(\.\*|\*|\+|\.\^|\.\\|\.\/|\/|\\)", OPERATOR),

                (r"(\[|\]|\(|\)|\{|\}|:|@|\.|,)", PUNCTUATION),
                (r"(=|:|;)", PUNCTUATION),

                (r"(?<=[\w)\].])'+", OPERATOR),

                (r"(\d+\.\d*|\d*\.\d+)([eEf][+-]?[0-9]+)?", NUMBER_FLOAT),
                (r"\d+[eEf][+-]?[0-9]+", NUMBER_FLOAT),
                (r"\d+", NUMBER_INTEGER),

                (r"(?<![\w)\].])'", STRING, :string),
                (r"([a-zA-Z_]\w*)(\()", (NAME_FUNCTION, PUNCTUATION)),
                (r"[a-zA-Z_]\w*", NAME),
                (r".", TEXT),
            ],
            :blockcomment => Any[
                (r"^\s*%\}"ms, COMMENT_MULTILINE, :__pop__),
                (r"."sm, COMMENT_MULTILINE),
            ],
            :deffunc => [
                (
                    r"(\s*)(?:(.+)(\s*)(=)(\s*))?(.+)(\()(.*)(\))(\s*)",
                    (
                        WHITESPACE, TEXT, WHITESPACE, PUNCTUATION, WHITESPACE,
                        NAME_FUNCTION, PUNCTUATION, TEXT, PUNCTUATION, WHITESPACE,
                    ),
                    :__pop__,
                ),
                (r"(\s*)([a-zA-Z_]\w*)", (TEXT, NAME_FUNCTION), :__pop__),
            ],
            :string => [
                (r"[^']*'", STRING, :__pop__),
            ],
        ),
    )
end
