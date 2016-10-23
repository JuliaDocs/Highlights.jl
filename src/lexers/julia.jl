import ..Highlights.Compiler: NULL_RANGE, Context

function definition(::Type{JuliaLexer})
    local keywords = Base.REPLCompletions.complete_keyword("")
    local char_regex = [
        raw"'(\\.|\\[0-7]{1,3}|\\x[a-fA-F0-9]{1,3}|",
        raw"\\u[a-fA-F0-9]{1,4}|\\U[a-fA-F0-9]{1,6}|",
        raw"[^\\\'\n])'",
    ]
    return Dict(
        :name => "Julia",
        :aliases => ["julia", "jl"],
        :filenames => ["*.jl"],
        :mimetypes => ["text/x-julia", "application/x-julia"],
        :tokens => Dict(
            :root => [
                (r"\n"m, :text),
                (r"[^\S\n]+"m, :text),
                (r"#=", :comment_multiline, :block_comments),
                (r"#.*$"m, :comment_singleline),
                (r"[\[\]{}(),;]", :punctuation),

                (r"\b(?<![:_.])in\b", :keyword_pseudo),
                (r"\b(?<![_.])end\b", :keyword_end),
                (r"\b(?<![:_.])(true|false)\b", :keyword_constant),
                (r"\b(?<![:_.])(local|global|const)\b", :keyword_declaration),
                (words(keywords, prefix = "\\b(?<![:_.])", suffix = "\\b"), :keyword),

                (Regex(join(char_regex)), :string_char),

                (r"\"\"\"", :string, :triple_strings),
                (r"\"", :string, :strings),

                (julia_is_triple_string_macro, :string_macro, :triple_string_macros),
                (julia_is_string_macro, :string_macro, :string_macros),

                (r"`", :string_backtick, :commands),

                (julia_is_method_call, :name_function),
                (julia_is_identifier, :name),
                (julia_is_macro_identifier, :name_decorator),

                (r"(\d+(_\d+)+\.\d*|\d*\.\d+(_\d+)+)([eEf][+-]?[0-9]+)?", :number_float),
                (r"(\d+\.\d*|\d*\.\d+)([eEf][+-]?[0-9]+)?", :number_float),
                (r"\d+(_\d+)+[eEf][+-]?[0-9]+", :number_float),
                (r"\d+[eEf][+-]?[0-9]+", :number_float),
                (r"0b[01]+(_[01]+)+", :number_bin),
                (r"0b[01]+", :number_bin),
                (r"0o[0-7]+(_[0-7]+)+", :number_oct),
                (r"0o[0-7]+", :number_oct),
                (r"0x[a-fA-F0-9]+(_[a-fA-F0-9]+)+", :number_hex),
                (r"0x[a-fA-F0-9]+", :number_hex),
                (r"\d+(_\d+)+", :number_integer),
                (r"\d+", :number_integer),

                (r"[^[:alnum:]\s()\[\]{},;@_\"\']+", :operator),

                (r"."ms, :text),
            ],
            :block_comments => [
                (r"[^#=]", :comment_multiline),
                (r"#=", :comment_multiline, :__push__),
                (r"=#", :comment_multiline, :__pop__),
                (r"[=#]", :comment_multiline),
            ],
            :commands => [
                (r"`", :string_backtick, :__pop__),
                (julia_is_iterp_identifier, :string_iterpol),
                (r"(\$)(\()", (:string_iterpol, :punctuation), :in_interpol),
                (r".|\s"ms, :string_backtick),
            ],
            :strings => [
                (r"\"", :string, :__pop__),
                (r"\\([\\\"\'\$nrbtfav]|(x|u|U)[a-fA-F0-9]+|\d+)", :string_escape),
                (julia_is_iterp_identifier, :string_iterpol),
                (r"(\$)(\()", (:string_iterpol, :punctuation), :in_interpol),
                (r".|\s"ms, :string),
            ],
            :triple_strings => [
                (r"\"\"\"", :string, :__pop__),
                (r"\\([\\\"\'\$nrbtfav]|(x|u|U)[a-fA-F0-9]+|\d+)", :string_escape),
                (julia_is_iterp_identifier, :string_iterpol),
                (r"(\$)(\()", (:string_iterpol, :punctuation), :in_interpol),
                (r".|\s"ms, :string),
            ],
            :string_macros => [
                (r"\"", :string_macro, :__pop__),
                (r"\\\"", :string_macro),
                (r".|\s"ms, :string_macro),
            ],
            :triple_string_macros => [
                (r"\"\"\"", :string_macro, :__pop__),
                (r".|\s"ms, :string_macro),
            ],
            :in_interpol => [
                (r"\(", :punctuation, :__push__),
                (r"\)", :punctuation, :__pop__),
                :root,
            ],
        ),
    )
end

function julia_is_identifier(ctx::Context, prefix = '\0')
    s = ctx.source
    i = ctx.pos[]
    done(s, i) && return NULL_RANGE
    (c, i) = next(s, i)
    if prefix !== '\0'
        (c === prefix && !done(s, i)) || return NULL_RANGE
        (c, i) = next(s, i)
    end
    Base.is_id_start_char(c) || return NULL_RANGE
    local prev_i = i
    while !done(s, i)
        prev_i = i
        (c, i) = next(s, i)
        Base.is_id_char(c) || break
    end
    return ctx.pos[]:prevind(s, prev_i)
end
julia_is_macro_identifier(ctx::Context) = julia_is_identifier(ctx, '@')
julia_is_iterp_identifier(ctx::Context) = julia_is_identifier(ctx, '$')

function julia_is_method_call(ctx::Context)
    local range = julia_is_identifier(ctx)
    range === NULL_RANGE && return range
    i = nextind(ctx.source, last(range))
    done(ctx.source, i) && return NULL_RANGE
    (c, i) = next(ctx.source, i)
    return (c === '(' || c === '{') ? range : NULL_RANGE
end

function julia_is_string_macro(ctx::Context, count::Integer = 1)
    local range = julia_is_identifier(ctx)
    range == NULL_RANGE && return NULL_RANGE
    local s = ctx.source
    local i = prevind(s, ctx.pos[] + length(range) + 1)
    local num = 0
    while num < count && !done(s, i)
        (c, i) = next(s, i)
        c === '"' ? (num += 1) : break
    end
    num == count ? (ctx.pos[]:prevind(s, i)) : NULL_RANGE
end
julia_is_triple_string_macro(ctx::Context) = julia_is_string_macro(ctx, 3)
