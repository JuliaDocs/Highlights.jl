definition(::Type{MonokaiTheme}) = Dict(
    :name => "Monokai",
    :description => "A style that mimics the Monokai color scheme.",
    :comments => "Based on the Monokai theme from Pygments.",
    :style => S"bg: 272822; fg: 49483e",
    :tokens => Dict(
        COMMENT                   => S"fg: 75715e",
        COMMENT_MULTILINE         => S"",
        COMMENT_PREPROC           => S"",
        COMMENT_SINGLE            => S"",
        COMMENT_SPECIAL           => S"",

        ERROR                     => S"fg: 960050; bg: 1e0010",

        GENERIC                   => S"",
        GENERIC_DELETED           => S"fg: f92672",
        GENERIC_EMPH              => S"italic",
        GENERIC_ERROR             => S"",
        GENERIC_HEADING           => S"",
        GENERIC_INSERTED          => S"fg: a6e22e",
        GENERIC_OUTPUT            => S"",
        GENERIC_PROMPT            => S"",
        GENERIC_STRONG            => S"bold",
        GENERIC_SUBHEADING        => S"fg: 75715e",
        GENERIC_TRACEBACK         => S"",

        KEYWORD                   => S"fg: 66d9ef",
        KEYWORD_CONSTANT          => S"",
        KEYWORD_DECLARATION       => S"",
        KEYWORD_NAMESPACE         => S"fg: f92672",
        KEYWORD_PSEUDO            => S"",
        KEYWORD_RESERVED          => S"",
        KEYWORD_TYPE              => S"",

        LITERAL                   => S"fg: ae81ff",
        LITERAL_DATE              => S"fg: e6db74",

        NAME                      => S"fg: f8f8f2",
        NAME_ATTRIBUTE            => S"fg: a6e22e",
        NAME_BUILTIN              => S"",
        NAME_BUILTIN_PSEUDO       => S"",
        NAME_CLASS                => S"fg: a6e22e",
        NAME_CONSTANT             => S"fg: 66d9ef",
        NAME_DECORATOR            => S"fg: a6e22e",
        NAME_ENTITY               => S"",
        NAME_EXCEPTION            => S"fg: a6e22e",
        NAME_FUNCTION             => S"fg: a6e22e",
        NAME_LABEL                => S"",
        NAME_NAMESPACE            => S"",
        NAME_OTHER                => S"fg: a6e22e",
        NAME_PROPERTY             => S"",
        NAME_TAG                  => S"fg: f92672",
        NAME_VARIABLE             => S"",
        NAME_VARIABLE_CLASS       => S"",
        NAME_VARIABLE_GLOBAL      => S"",
        NAME_VARIABLE_INSTANCE    => S"",

        NUMBER                    => S"fg: ae81ff",
        NUMBER_FLOAT              => S"",
        NUMBER_HEX                => S"",
        NUMBER_INTEGER            => S"",
        NUMBER_INTEGER_LONG       => S"",
        NUMBER_OCT                => S"",

        OPERATOR                  => S"fg: f92672",
        OPERATOR_WORD             => S"",

        OTHER                     => S"",

        PUNCTUATION               => S"fg: f8f8f2",

        STRING                    => S"fg: e6db74",
        STRING_BACKTICK           => S"",
        STRING_CHAR               => S"",
        STRING_DOC                => S"",
        STRING_DOUBLE             => S"",
        STRING_ESCAPE             => S"fg: ae81ff",
        STRING_HEREDOC            => S"",
        STRING_INTERPOL           => S"",
        STRING_OTHER              => S"",
        STRING_REGEX              => S"",
        STRING_SINGLE             => S"",
        STRING_SYMBOL             => S"",

        TEXT                      => S"fg: f8f8f2",

        WHITESPACE                => S"",
    )
)