module External

using Highlights
using Highlights.Lexers
using Highlights.Tokens

abstract type CommentLexer <: AbstractLexer end

@lexer CommentLexer Dict(
    :name => "Comments",
    :description => "A C-style comment lexer.",
    :tokens => Dict(
        :root => [
            (r"//.*\n", COMMENT_SINGLE),
            (r"/\*",    COMMENT_MULTILINE,   :multiline_comments),
            (r"[^/]+",  TEXT)
        ],
        :multiline_comments => [
            (r"/\*",     COMMENT_MULTILINE,  :__push__),
            (r"\*/",     COMMENT_MULTILINE,  :__pop__),
            (r"[^/\*]+", COMMENT_MULTILINE),
        ],
    )
)

end
