@theme XcodeTheme Dict(
    :name => "Xcode",
    :description => "Style similar to the Xcode default colouring theme.",
    :comments => "Based on the Xcode theme from Pygments.",
    :tokens => Dict(
        COMMENT             => S"fg: 177500",
        COMMENT_PREPROC     => S"fg: 633820",

        ERROR               => S"fg: 000000",

        KEYWORD             => S"fg: A90D91",

        LITERAL             => S"fg: 1C01CE",

        NAME                => S"fg: 000000",
        NAME_ATTRIBUTE      => S"fg: 836C28",
        NAME_BUILTIN        => S"fg: A90D91",
        NAME_BUILTIN_PSEUDO => S"fg: 5B269A",
        NAME_CLASS          => S"fg: 3F6E75",
        NAME_DECORATOR      => S"fg: 000000",
        NAME_FUNCTION       => S"fg: 000000",
        NAME_LABEL          => S"fg: 000000",
        NAME_TAG            => S"fg: 000000",
        NAME_VARIABLE       => S"fg: 000000",

        NUMBER              => S"fg: 1C01CE",

        OPERATOR            => S"fg: 000000",

        STRING              => S"fg: C41A16",
        STRING_CHAR         => S"fg: 2300CE",

        TEXT                => S"",
    )
)
