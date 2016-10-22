definition(::Type{DefaultTheme}) = Dict(
    :name => "Default",
    :description => "Based on the official Julia colours.",
    :style => S"bg: fbfbfb; fg: 444",
    :tokens => Dict(
        :text => S"",
        :keyword => S"fg: 945bb0; bold",
        :keyword_constant => S"fg: 3b972e; italic",
        :keyword_declaration => S"fg: d66661; italic",
        :string => S"fg: c93d39",
        :string_escape => S"fg: 3b972e",
        :string_iterpol => S"",
        :literal_date => S"fg: 945bb0; italic",
        :comment => S"fg: 999977; italic",
        :number => S"fg: 3b972e",
        :name_function => S"fg: 4266d5",
        :name_decorator => S"fg: d66661",
        :operator => S"bold; fg: 666666",
    )
)

