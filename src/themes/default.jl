abstract DefaultTheme <: AbstractTheme

definition(::Type{DefaultTheme}) = Dict(
    :name => "Default Theme",
    :comments => "Based on the default theme provided by Pygments.",
    :tokens => Dict(
        :text               => S"",
        :error              => S"fg:ffffff; bg:ff3300",

        :whitespace         => S"fg:bbbbbb",
        :comment            => S"italic; fg:408080",
        :comment_preproc    => S"fg:BC7A00",

        :keyword            => S"bold; fg:008000",
        :keyword_pseudo     => S"",
        :keyword_type       => S"fg:B00040",

        :operator           => S"fg:666666",
        :operator_word      => S"bold; fgAA22FF",

        :name_builtin       => S"fg:008000",
        :name_function      => S"fg:0000FF",
        :name_class         => S"bold; fg:0000FF",
        :name_namespace     => S"bold; fg:0000FF",
        :name_exception     => S"bold; fg:D2413A",
        :name_variable      => S"fg:19177C",
        :name_constant      => S"fg:880000",
        :name_label         => S"fg:A0A000",
        :name_entity        => S"bold; fg:999999",
        :name_attribute     => S"fg:7D9029",
        :name_tag           => S"bold; fg:008000",
        :name_decorator     => S"fg:AA22FF",

        :string             => S"fg:BA2121",
        :string_doc         => S"italic",
        :string_interpol    => S"bold; fg:BB6688",
        :string_escape      => S"bold; fg:BB6622",
        :string_regex       => S"fg:BB6688",
        :string_symbol      => S"fg:19177C",
        :string_other       => S"fg:008000",

        :number             => S"fg:666666",

        :generic            => S"",
        :generic_heading    => S"bold; fg:000080",
        :generic_subheading => S"bold; fg:800080",
        :generic_deleted    => S"fg:A00000",
        :generic_inserted   => S"fg:00A000",
        :generic_error      => S"fg:FF0000",
        :generic_emph       => S"italic",
        :generic_strong     => S"bold",
        :generic_prompt     => S"bold; fg:000080",
        :generic_output     => S"fg:888",
        :generic_traceback  => S"fg:04D",
    )
)
