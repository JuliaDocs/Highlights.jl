@lexer PTXLexer Dict(
    :name => "PTX Lexer",
    :description => "A PTX(Parallel Thread Execution) lexer. Virtual ISA for NVIDIA GPU's",
    :tokens => Dict(
        :root => [
            (r"//[^\n]*\n", COMMENT_SINGLE),
			(r"[ \t\n]+", WHITESPACE),
			(r"\w+:", NAME_LABEL),
			(r"bra[^\n]+\n", :branch),
			(Regex("(" * r_number * ")") * r"([ \t()\n,;\]])", (NUMBER, TEXT)),
			(r"(\.\w+)([ \t,\.])", (:dot_token, TEXT)),
			(r"(\w+)([ \t,\.\n;\[()\+\]])", (:identifier, TEXT)),
			(r"@?%\w+(?:<\d+>)?(\.x)?", :register),
            (r"/\*",    COMMENT_MULTILINE,   :multiline_comments),
        ],
		:branch => [
			(r"bra", KEYWORD),
			(r"[ \t]+", WHITESPACE),
			(r"(\.\w+)([ \t,\.])", (:dot_token, TEXT)),
			(r"(\w+)([^ \t\.])", (NAME_LABEL, TEXT)),
			(r";", TEXT, :__pop__)
		],
		:dot_token => [
			(r"\.func[^\w]", NAME_FUNCTION, :__pop__),
			(r"\." * Lexers.words(vcat(ptx_instructions, directives, operators)), KEYWORD, :__pop__),
			(r"\.\w+[^\w]", TEXT, :__pop__),
			(r"\w+[^\w]", TEXT, :__pop__)
		],
		 :register => [
		 	(r"@?%\w+(?:<\d+>)?(\.x)?", LITERAL, :__pop__)
		 ],
		:identifier => [
			(Lexers.words(predefined_identifiers), KEYWORD, :__pop__),
			(Lexers.words(ptx_instructions), KEYWORD, :__pop__),
			(Lexers.words(operators), KEYWORD, :__pop__),
			(Regex(r_identifier), TEXT, :__pop__),
		],
        :multiline_comments => [
            (r"/\*",     COMMENT_MULTILINE,  :__push__),
            (r"\*/",     COMMENT_MULTILINE,  :__pop__),
            (r"[^/\*]+", COMMENT_MULTILINE),
        ],
    )
)
