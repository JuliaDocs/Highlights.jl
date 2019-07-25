# Lexer Guide

New lexer definitions are added in a similar manner to those for themes. For this guide
we'll be creating a really simple lexer that can highlight C/C++ style comments and nested
multiline comments.

## A Basic Lexer

First, we import the necessary names from the `Tokens` and `Lexers` submodules.

```@example 1
using Highlights.Tokens, Highlights.Lexers
```

`Tokens` provides all the named tokens, such as `COMMENT_SINGLE`, while `Lexers` provides
the `AbstractLexer` type and `@lexer` macro.

Next we define a new type to represent our lexer.

```@example 1
abstract type CommentLexer <: AbstractLexer end
```

!!! note

    We define the type and the definition separately so that we are able to reference one
    lexer from another definition without encountering `UndefVarError`s.

Finally we add a definition for our new lexer using the `@lexer` macro. We'll list the
entire definition and then go over each part individually.

```@example 1
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
nothing # hide
```

So how does it work?

The first line looks similar to the `@theme` macro usage in the previous section. The
`@lexer` macro takes two arguments -- the lexer name and it's definition `Dict`. The `Dict`
contains all the *rules* used to tokenise source code that gets passed to the generated
lexer.

Several *metadata* fields should also be provided. `:name` provides a human-readable name
for the lexer. `:description` provides some basic details about the lexer and what it is
for.

`:tokens` is a `Dict` of different *states* that the lexer steps through while trying to
determine what to do with each character of a string. In this lexer we have two states --
`:root` and `:multiline_comments`.

!!! note

    The lexer *always* starts in the `:root` *state*, so this is the only *state* that
    **needs** to be provided. You may find that some lexer definitions can be written with
    only a `:root` *state*, while others may need a significant number of different *states*
    to function correctly.

Each *state* is a `Vector` of *rules* that are tested against sequentially until one matches
the current position in the source code that we are trying to highlight. On a successful
match we move the current position forward and start again at the first rule of the current
state.

In the `:root` state of our `CommentLexer` we begin with

```julia
(r"//.*\n", COMMENT_SINGLE)
```

which tests whether the current position in our source code matches the given regular
expression `r"//.*"`, i.e. a single line comment such as

```text
// This is a singleline comment.
```

If it matches then we create a new `COMMENT_SINGLE` *token* that spans the entire
match -- from `/` to `.` in the above example.

When the rule does not match we then move onto the next one:

```julia
("r/\*", COMMENT_MULTILINE, :multiline_comments)
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

When this rule is successfully matched, like in the previous example, we create a new
`COMMENT_MULTILINE` *token* and move passed the match. Instead of going back to the start of
the current state though, we first enter a new state called `:multiline_comments`. Once that
state returns we then jump back to the first rule of the `:root` state.

The last rule of the `:root` state isn't all that interesting:

```julia
(r"[^/]+", TEXT)
```

This just matches any non-comment characters and assigns them to a `TEXT` *token*.

Now lets look at the `:multiline_comments` state.

```julia
(r"/\*", COMMENT_MULTILINE, :__push__),
```

When the above rule matches (i.e. the start of a multiline comment) then we enter a special
state called `:__push__`. What `:__push__` does is just call the current *state* again, so
internally we *push* a new function call onto the call stack.

A similar naming scheme is used for the `:__pop__` state, where we `return` from the current
*state* and so *pop* the current function call off the call stack:

```julia
(r"\*/", COMMENT_MULTILINE, :__pop__),
```

And the last rule, similar to the `TEXT` *rule* in `:root`, just matches all non multiline
comment characters and assigns the result to a `COMMENT_MULTILINE` *token*:

```julia
(r"[^/\*]+", COMMENT_MULTILINE),
```

!!! note

    All the *tokens* in `:multiline_comments` are assigned to `COMMENT_MULTILINE`. This is
    because when we are inside a nested comment everything will be a multiline comment.

That's all there is to writing a *basic* lexer. There are a couple of other *rule* types
that can be used to make more complex lexers, which are described at the end of this section
of the manual. First, though, we'll `highlight` some text using this new lexer to see
whether it works correctly.

```@example 1
using Highlights # Imports `stylesheet` and `highlight`.

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
    stylesheet(stream, MIME("text/html"))
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

    **Do not** create a *cycle* between two or more states by including *states* within each
    other recursively.

### Custom Matchers

```julia
(custom_matcher, TOKEN_NAME)
```

Use a custom function as the matcher rather than a regular expression. This function must
take a `Compiler.Context` object and return a `UnitRange{Int}` as the result. A range of
`0:0` signifies *no match*.

!!! warning

    Using matcher functions and interacting with `Compiler.Context` objects is still subject
    to change and should be considered **unstable** and **non-public** currently.

    It is included here only for the sake of completeness and to allow readers of some of
    the lexers in `src/lexers` to more easily understand their use.

### Regular Expression Groups

```julia
(r"(group_one)(group_two)", (GROUP_ONE_TOKEN, GROUP_TWO_TOKEN))
```

Assigns two or more *tokens* at once based on the capture groups present in the regular
expression that is used. Token count and group count **must** match exactly and all parts of
the matching substring must be covered by exactly one group with no overlap between groups.

### Calling Other Lexers

```julia
(r"...", OtherLexer)
```

Tokenise the source code matched by `r"..."` using a different lexer called `OtherLexer` --
starting from it's `:root` state.

```julia
(r"...", :other_state)
```

Use the current lexer's `:other_state` *state* to tokenise source code matched by `r"..."`.

!!! note

    Additionally, the previous two examples can be combined to call another lexer, but
    starting at the specified *state*, i.e.

    ```julia
    (r"...", OtherLexer => :other_state)
    ```

### State Queues

```julia
(r"...", :token, (:state_3, :state_2, :state_1))
```

Push a tuple of *states* onto the lexer stack that will be called from right to left.

### Inheriting Rules

If a lexer is defined as a subtype of another lexer, say

```@setup inheriting-lexers
using Highlights.Lexers, Highlights.Tokens
```

```@example inheriting-lexers
abstract type Parent <: AbstractLexer end
abstract type Child <: Parent end
```

Then `Child` can use `:__inherit__` to include the rules from an ancestor's state within the
current rule set, i.e.

```@example inheriting-lexers
@lexer Parent Dict(
    :tokens => Dict(
        :root => [
            (r"\d+", NUMBER),
        ],
    ),
)

@lexer Child Dict(
    :tokens => Dict(
        :root => [
            :__inherit__,
            (r"\w+", NAME),
        ],
    ),
)
nothing # hide
```

In the above example `Parent` will tokenise `NUMBER`s and `Child` will tokenise `NAME`s in
addition to tokenising `NUMBER`s like it's parent lexer.

!!! note

    For all the above *rules* a regular expression and custom matcher function can be
    interchanged **except** for the capture groups *rule*.
