definition(::Type{VimTheme}) = Dict(
    :name => "Vim Theme",
    :description => "A theme similar to the vim 7.0 default theme.",
    :comments => "Based on the theme from Pygments.",
    :style => S"bg: 000000; fg: cccccc",
    :tokens => Dict(
        :comment             => S"fg: 000080",
        :comment_preproc     => S"",
        :comment_special     => S"bold; fg: cd0000",

        :error               => S"bg: ff0000",

        :generic_deleted     => S"fg: cd0000",
        :generic_emph        => S"italic",
        :generic_error       => S"fg: ff0000",
        :generic_heading     => S"bold; fg: 000080",
        :generic_inserted    => S"fg: 00cd00",
        :generic_output      => S"fg: 888",
        :generic_prompt      => S"bold; fg: 000080",
        :generic_strong      => S"bold",
        :generic_subheading  => S"bold; fg: 800080",
        :generic_traceback   => S"fg: 04d",

        :keyword             => S"fg: cdcd00",
        :keyword_declaration => S"fg: 00cd00",
        :keyword_namespace   => S"fg: cd00cd",
        :keyword_pseudo      => S"",
        :keyword_type        => S"fg: 00cd00",

        :name                => S"",
        :name_builtin        => S"fg: cd00cd",
        :name_class          => S"fg: 00cdcd",
        :name_exception      => S"bold; fg: 666699",
        :name_variable       => S"fg: 00cdcd",

        :number              => S"fg: cd00cd",

        :operator            => S"fg: 3399cc",
        :operator_word       => S"fg: cdcd00",

        :string              => S"fg: cd0000",

        :text                => S"",
        :token               => S"fg: cccccc",

        :whitespace          => S"",
    )
)
