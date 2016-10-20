definition(::Type{EmacsTheme}) = Dict(
    :name => "Emacs Theme",
    :description => "A theme inspired by Emacs 22.",
    :comments => "Based on the Emacs theme from Pygments.",
    :style => S"bg: f8f8f8",
    :tokens => Dict(
        :comment            => S"italic; fg: 008800",
        :comment_preproc    => S"",
        :comment_special    => S"bold",

        :error              => S"bg: ff0000; fg: ff3300",

        :generic_deleted    => S"fg: a00000",
        :generic_emph       => S"italic",
        :generic_error      => S"fg: ff0000",
        :generic_heading    => S"bold; fg: 000080",
        :generic_inserted   => S"fg: 00a000",
        :generic_output     => S"fg: 888",
        :generic_prompt     => S"bold; fg: 000080",
        :generic_strong     => S"bold",
        :generic_subheading => S"bold; fg: 800080",
        :generic_traceback  => S"fg: 04d",

        :keyword            => S"bold; fg: aa22ff",
        :keyword_pseudo     => S"",
        :keyword_type       => S"bold; fg: 00bb00",

        :name               => S"",
        :name_attribute     => S"fg: bb4444",
        :name_builtin       => S"fg: aa22ff",
        :name_class         => S"fg: 0000ff",
        :name_constant      => S"fg: 880000",
        :name_decorator     => S"fg: aa22ff",
        :name_entity        => S"bold; fg: 999999",
        :name_exception     => S"bold; fg: d2413a",
        :name_function      => S"fg: 00a000",
        :name_label         => S"fg: a0a000",
        :name_namespace     => S"bold; fg: 0000ff",
        :name_tag           => S"bold; fg: 008000",
        :name_variable      => S"fg: b8860b",

        :number             => S"fg: 666666",

        :operator           => S"fg: 666666",
        :operator_word      => S"bold; fg: aa22ff",

        :string             => S"fg: bb4444",
        :string_doc         => S"italic",
        :string_escape      => S"bold; fg: bb6622",
        :string_interpol    => S"bold; fg: bb6688",
        :string_other       => S"fg: 008000",
        :string_regex       => S"fg: bb6688",
        :string_symbol      => S"fg: b8860b",

        :text               => S"",

        :whitespace         => S"fg: bbbbbb",
    )
)
