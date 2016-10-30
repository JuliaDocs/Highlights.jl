@theme PygmentsTheme Dict(
    :name => "Pygments",
    :description => "Based on the default theme provided by Pygments.",
    :tokens => Dict(
        TEXT               => S"",
        ERROR              => S"fg:ffffff; bg:ff3300",

        WHITESPACE         => S"fg:bbbbbb",
        COMMENT            => S"italic; fg:408080",
        COMMENT_PREPROC    => S"fg:BC7A00",

        KEYWORD            => S"bold; fg:008000",
        KEYWORD_PSEUDO     => S"",
        KEYWORD_TYPE       => S"fg:B00040",

        OPERATOR           => S"fg:666666",
        OPERATOR_WORD      => S"bold; fgAA22FF",

        NAME_BUILTIN       => S"fg:008000",
        NAME_FUNCTION      => S"fg:0000FF",
        NAME_CLASS         => S"bold; fg:0000FF",
        NAME_NAMESPACE     => S"bold; fg:0000FF",
        NAME_EXCEPTION     => S"bold; fg:D2413A",
        NAME_VARIABLE      => S"fg:19177C",
        NAME_CONSTANT      => S"fg:880000",
        NAME_LABEL         => S"fg:A0A000",
        NAME_ENTITY        => S"bold; fg:999999",
        NAME_ATTRIBUTE     => S"fg:7D9029",
        NAME_TAG           => S"bold; fg:008000",
        NAME_DECORATOR     => S"fg:AA22FF",

        STRING             => S"fg:BA2121",
        STRING_DOC         => S"italic",
        STRING_INTERPOL    => S"bold; fg:BB6688",
        STRING_ESCAPE      => S"bold; fg:BB6622",
        STRING_REGEX       => S"fg:BB6688",
        STRING_SYMBOL      => S"fg:19177C",
        STRING_OTHER       => S"fg:008000",

        NUMBER             => S"fg:666666",

        GENERIC            => S"",
        GENERIC_HEADING    => S"bold; fg:000080",
        GENERIC_SUBHEADING => S"bold; fg:800080",
        GENERIC_DELETED    => S"fg:A00000",
        GENERIC_INSERTED   => S"fg:00A000",
        GENERIC_ERROR      => S"fg:FF0000",
        GENERIC_EMPH       => S"italic",
        GENERIC_STRONG     => S"bold",
        GENERIC_PROMPT     => S"bold; fg:000080",
        GENERIC_OUTPUT     => S"fg:888",
        GENERIC_TRACEBACK  => S"fg:04D",
    )
)
