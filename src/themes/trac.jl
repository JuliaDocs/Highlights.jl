@theme TracTheme Dict(
    :name => "Trac",
    :description => "Based on the default trac highlighter design.",
    :comments => "Based on the theme from Pygments.",
    :tokens => Dict(
        COMMENT             => S"italic; fg: 999988",
        COMMENT_PREPROC     => S"bold; fg: 999999",
        COMMENT_SPECIAL     => S"bold; fg: 999999",

        ERROR               => S"bg: e3d2d2; fg: a61717",

        GENERIC_DELETED     => S"bg: ffdddd; fg: 000000",
        GENERIC_EMPH        => S"italic",
        GENERIC_ERROR       => S"fg: aa0000",
        GENERIC_HEADING     => S"fg: 999999",
        GENERIC_INSERTED    => S"bg: ddffdd; fg: 000000",
        GENERIC_OUTPUT      => S"fg: 888888",
        GENERIC_PROMPT      => S"fg: 555555",
        GENERIC_STRONG      => S"bold",
        GENERIC_SUBHEADING  => S"fg: aaaaaa",
        GENERIC_TRACEBACK   => S"fg: aa0000",

        KEYWORD             => S"bold",
        KEYWORD_TYPE        => S"fg: 445588",

        NAME_ATTRIBUTE      => S"fg: 008080",
        NAME_BUILTIN        => S"fg: 999999",
        NAME_CLASS          => S"bold; fg: 445588",
        NAME_CONSTANT       => S"fg: 008080",
        NAME_ENTITY         => S"fg: 800080",
        NAME_EXCEPTION      => S"bold; fg: 990000",
        NAME_FUNCTION       => S"bold; fg: 990000",
        NAME_NAMESPACE      => S"fg: 555555",
        NAME_TAG            => S"fg: 000080",
        NAME_VARIABLE       => S"fg: 008080",

        NUMBER              => S"fg: 009999",

        OPERATOR            => S"bold",

        STRING              => S"fg: bb8844",
        STRING_REGEX        => S"fg: 808000",

        TEXT                => S"",

        WHITESPACE          => S"fg: bbbbbb",
    )
)
