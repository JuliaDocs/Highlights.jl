definition(::Type{XcodeTheme}) = Dict(
    :name => "Xcode",
    :description => "Style similar to the Xcode default colouring theme.",
    :comments => "Based on the Xcode theme from Pygments.",
    :tokens => Dict(
        :comment             => S"fg: 177500",
        :comment_preproc     => S"fg: 633820",

        :error               => S"fg: 000000",

        :keyword             => S"fg: A90D91",

        :literal             => S"fg: 1C01CE",

        :name                => S"fg: 000000",
        :name_attribute      => S"fg: 836C28",
        :name_builtin        => S"fg: A90D91",
        :name_builtin_pseudo => S"fg: 5B269A",
        :name_class          => S"fg: 3F6E75",
        :name_decorator      => S"fg: 000000",
        :name_function       => S"fg: 000000",
        :name_label          => S"fg: 000000",
        :name_tag            => S"fg: 000000",
        :name_variable       => S"fg: 000000",

        :number              => S"fg: 1C01CE",

        :operator            => S"fg: 000000",

        :string              => S"fg: C41A16",
        :string_char         => S"fg: 2300CE",

        :text                => S"",
    )
)
