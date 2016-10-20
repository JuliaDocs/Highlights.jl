definition(::Type{TracTheme}) = Dict(
    :name => "Trac Theme",
    :description => "A theme based on the default trac highlighter design.",
    :comments => "Based on the theme from Pygments.",
    :tokens => Dict(
        :comment             => S"italic; fg: 999988",
        :comment_preproc     => S"bold; fg: 999999",
        :comment_special     => S"bold; fg: 999999",

        :error               => S"bg: e3d2d2; fg: a61717",

        :generic_deleted     => S"bg: ffdddd; fg: 000000",
        :generic_emph        => S"italic",
        :generic_error       => S"fg: aa0000",
        :generic_heading     => S"fg: 999999",
        :generic_inserted    => S"bg: ddffdd; fg: 000000",
        :generic_output      => S"fg: 888888",
        :generic_prompt      => S"fg: 555555",
        :generic_strong      => S"bold",
        :generic_subheading  => S"fg: aaaaaa",
        :generic_traceback   => S"fg: aa0000",

        :keyword             => S"bold",
        :keyword_type        => S"fg: 445588",

        :name_attribute      => S"fg: 008080",
        :name_builtin        => S"fg: 999999",
        :name_class          => S"bold; fg: 445588",
        :name_constant       => S"fg: 008080",
        :name_entity         => S"fg: 800080",
        :name_exception      => S"bold; fg: 990000",
        :name_function       => S"bold; fg: 990000",
        :name_namespace      => S"fg: 555555",
        :name_tag            => S"fg: 000080",
        :name_variable       => S"fg: 008080",

        :number              => S"fg: 009999",

        :operator            => S"bold",

        :string              => S"fg: bb8844",
        :string_regex        => S"fg: 808000",

        :text                => S"",

        :whitespace          => S"fg: bbbbbb",
    )
)
