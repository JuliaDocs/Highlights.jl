@theme EmacsTheme Dict(
    :name => "Emacs",
    :description => "A theme inspired by Emacs 22.",
    :comments => "Based on the Emacs theme from Pygments.",
    :style => S"bg: f8f8f8",
    :tokens => Dict(
        COMMENT            => S"italic; fg: 008800",
        COMMENT_PREPROC    => S"",
        COMMENT_SPECIAL    => S"bold",

        ERROR              => S"bg: ff0000; fg: ff3300",

        GENERIC_DELETED    => S"fg: a00000",
        GENERIC_EMPH       => S"italic",
        GENERIC_ERROR      => S"fg: ff0000",
        GENERIC_HEADING    => S"bold; fg: 000080",
        GENERIC_INSERTED   => S"fg: 00a000",
        GENERIC_OUTPUT     => S"fg: 888",
        GENERIC_PROMPT     => S"bold; fg: 000080",
        GENERIC_STRONG     => S"bold",
        GENERIC_SUBHEADING => S"bold; fg: 800080",
        GENERIC_TRACEBACK  => S"fg: 04d",

        KEYWORD            => S"bold; fg: aa22ff",
        KEYWORD_PSEUDO     => S"",
        KEYWORD_TYPE       => S"bold; fg: 00bb00",

        NAME               => S"",
        NAME_ATTRIBUTE     => S"fg: bb4444",
        NAME_BUILTIN       => S"fg: aa22ff",
        NAME_CLASS         => S"fg: 0000ff",
        NAME_CONSTANT      => S"fg: 880000",
        NAME_DECORATOR     => S"fg: aa22ff",
        NAME_ENTITY        => S"bold; fg: 999999",
        NAME_EXCEPTION     => S"bold; fg: d2413a",
        NAME_FUNCTION      => S"fg: 00a000",
        NAME_LABEL         => S"fg: a0a000",
        NAME_NAMESPACE     => S"bold; fg: 0000ff",
        NAME_TAG           => S"bold; fg: 008000",
        NAME_VARIABLE      => S"fg: b8860b",

        NUMBER             => S"fg: 666666",

        OPERATOR           => S"fg: 666666",
        OPERATOR_WORD      => S"bold; fg: aa22ff",

        STRING             => S"fg: bb4444",
        STRING_DOC         => S"italic",
        STRING_ESCAPE      => S"bold; fg: bb6622",
        STRING_INTERPOL    => S"bold; fg: bb6688",
        STRING_OTHER       => S"fg: 008000",
        STRING_REGEX       => S"fg: bb6688",
        STRING_SYMBOL      => S"fg: b8860b",

        TEXT               => S"",

        WHITESPACE         => S"fg: bbbbbb",
    )
)
