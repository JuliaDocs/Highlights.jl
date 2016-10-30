@theme VimTheme Dict(
    :name => "Vim",
    :description => "A theme similar to the vim 7.0 default theme.",
    :comments => "Based on the theme from Pygments.",
    :style => S"bg: 000000; fg: cccccc",
    :tokens => Dict(
        COMMENT             => S"fg: 000080",
        COMMENT_PREPROC     => S"",
        COMMENT_SPECIAL     => S"bold; fg: cd0000",

        ERROR               => S"bg: ff0000",

        GENERIC_DELETED     => S"fg: cd0000",
        GENERIC_EMPH        => S"italic",
        GENERIC_ERROR       => S"fg: ff0000",
        GENERIC_HEADING     => S"bold; fg: 000080",
        GENERIC_INSERTED    => S"fg: 00cd00",
        GENERIC_OUTPUT      => S"fg: 888",
        GENERIC_PROMPT      => S"bold; fg: 000080",
        GENERIC_STRONG      => S"bold",
        GENERIC_SUBHEADING  => S"bold; fg: 800080",
        GENERIC_TRACEBACK   => S"fg: 04d",

        KEYWORD             => S"fg: cdcd00",
        KEYWORD_DECLARATION => S"fg: 00cd00",
        KEYWORD_NAMESPACE   => S"fg: cd00cd",
        KEYWORD_PSEUDO      => S"",
        KEYWORD_TYPE        => S"fg: 00cd00",

        NAME                => S"",
        NAME_BUILTIN        => S"fg: cd00cd",
        NAME_CLASS          => S"fg: 00cdcd",
        NAME_EXCEPTION      => S"bold; fg: 666699",
        NAME_VARIABLE       => S"fg: 00cdcd",

        NUMBER              => S"fg: cd00cd",

        OPERATOR            => S"fg: 3399cc",
        OPERATOR_WORD       => S"fg: cdcd00",

        STRING              => S"fg: cd0000",

        TEXT                => S"",

        WHITESPACE          => S"",
    )
)
