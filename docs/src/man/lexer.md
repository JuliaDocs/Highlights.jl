# Lexer Guide

New lexer definitions are added in a similar manner to those for themes. For this guide
we'll be creating a really simple lexer that can highlight C/C++ style comments and nested
multiline comments.

## A Basic Lexer

First, we import the necessary names from `Highlights`.

```@setup 1
using Highlights
```

```@example 1
import Highlights: AbstractLexer, definition
```

Then we define a new type to represent our lexer.

```@example 1
abstract CommentLexer <: AbstractLexer
```

Finally we add a method to the `definition` function.

!!! note

    `definition` here is the *same* function as used for themes in the previous section.

We'll list the entire definition and then go over each part individually.

```@example 1
definition(::Type{CommentLexer}) = Dict(
    :name => "Comments",
    :description => "A C-style comment lexer.",
    :tokens => Dict(
        :root => [
            (r"//.*\n", :comment_singleline),
            (r"/\*",    :comment_multiline,   :multiline_comments),
            (r"[^/]+",  :text)
        ],
        :multiline_comments => [
            (r"/\*",     :comment_multiline,  :__push__),
            (r"\*/",     :comment_multiline,  :__pop__),
            (r"[^/\*]+", :comment_multiline),
        ],
    )
)
nothing # hide
```

So how does it work?

Firstly, we define a new method of `definition` in a similar way to the previous section
on themes. This `definition` returns a `Dict` containing all the rules and metadata needed
to lex a string of source code containing `/*`, `//`, and `*/`.

`:name` is a metadata field that provides a human-readable name for the lexer.
`:description` provides some basic details about the lexer and what it is for.

`:tokens` is a `Dict` of different *states* that the lexer steps through while trying to
determine what to do with each character of a string. In this lexer we have two states --
`:root` and `:multiline_comments`.

!!! note

    The lexer *always* starts in the `:root` *state*, so this is the only *state* that needs
    to be provided. You may find that some lexer definitions can be written with only a
    `:root` *state*, while others may need a significant number of different *states*
    to function correctly.

Each *state* is a `Vector` of *rules* that are tested against sequentially until one matches
the current position in the source code that we are trying to lex. On a successful match we
move the current position forward and begin again at the first rule of the current state.

In the `:root` state of our `CommentLexer` we begin with

```julia
(r"//.*\n", :comment_singleline)
```

which tests whether the current position in our source code matches the given regular
expression `r"//.*"`, i.e. a single line comment such as

```text
// This is a singleline comment.
```

If it matches then we create a new `:comment_singleline` *token* that spans the entire
match -- from `/` to `.` in the above example.

When the rule does not match we then move onto the next one:

```julia
("r/\*", :comment_multiline, :multiline_comments)
```

which tries to match against a string starting with `/*`, i.e. the start of a multiline
comment such as

```text
/*
   A
   multiline
   comment.
 */
```

When this rule is successfully matched we, like in the previous example, create a new
`:comment_multiline` *token* and move passed the match. Instead of going back to the start
of the current state though, we first enter a new state called `:multiline_comments`. Once
that state returns then we jump back to the first rule of the `:root` state.

The last rule of the `:root` state isn't all that interesting:

```julia
(r"[^/]+", :text)
```

This just matches any non-comment characters and assigns them to a `:text` *token*.

Now lets look at the `:multiline_comments` state.

```julia
(r"/\*", :comment_multiline, :__push__),
```

When the above rule matches, i.e. the start of a multiline comment, then we enter a special
state called `:__push__`. What `:__push__` does is just call the current *state* again, so
internally we *push* a new function call onto the call stack.

A similar naming scheme is used for the `:__pop__` state, where we `return` from the current
*state* and so *pop* the current function call off the call stack:

```julia
(r"\*/", :comment_multiline, :__pop__),
```

And the last rule, similar to the `:text` *rule* in `:root`, just matches all non multiline
comment characters and assigns the result to a `:comment_multiline` *token*:

```julia
(r"[^/\*]+", :comment_multiline),
```

!!! note

    All the *tokens* in `:multiline_comments` are assigned to `:comment_multiline`. This is
    because when we are inside a nested comment everything will be a multiline comment.

That's all there is to writing a *basic* lexer. There are a couple of other *rule* types
that can be used to make more complex lexers, which are described at the end of this section
of the manual. First, though, we'll `highlight` some text using this new lexer to see
whether it works correctly.

```@example 1
source =
    """
    // A single line comment.

    This is not a comment.

    /*
       And a multiline one
       /* with a nested comment */
       inside.
     */

    This isn't a comment either.

    // And another single line // comment.
    """
open("comments-lexer.html", "w") do stream
    stylesheet(stream, MIME("text/html"), CommentLexer)
    highlight(stream, MIME("text/html"), source, CommentLexer)
end
```

*The resulting highlighted text can be see [here](comments-lexer.html).*

## Other Rules

There are several other *rules* available for building lexers. They are briefly outlined
below. To get a better idea of how to use these take a look at some of the lexers that are
defined in the `src/lexers/` directory.

### Including States

```julia
:name_of_state
```

This rule copies the contents of the `:name_of_state` *state* into another *state* to
help avoid duplicating rules.

!!! warning

    **De not** create a *cycle* between two or more states by including *states* within each
    other recursively.

```julia
(custom_matcher, :token_name)
```

Use a custom function as the matcher rather than a regular expression. This function must
take a `Compiler.Context` object and return a `UnitRange{Int}` as the result. A range of
`0:0` signifies *no match*.

```julia
(r"(group_one)(group_two)", (:group_one_token, :group_two_token))
```

Assigns two or more *tokens* at once based on the capture groups present in the regular
expression that is used. Token count and group count **must** match exactly.

```julia
(r"...", OtherLexer)
```

Lexer the source code matched by `r"..."` using a different lexer called `OtherLexer`.

```julia
(r"...", :token, (:state_3, :state_2, :state_1))
```

Push a tuple of *states* onto the lexer stack that will be called from right to left.

!!! note

    For all the above *rules* a regular expression and custom matcher function can be
    interchanged **except** for the capture groups *rule*.
