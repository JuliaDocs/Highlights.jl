#set page(margin: 1in)
#set text(font: "JetBrains Mono", size: 9pt)

#align(center)[
    #text(size: 24pt, weight: "bold")[Highlights.jl]
    #v(0.5em)
    #text(size: 12pt, fill: gray)[Syntax Highlighting Demo]
]

#v(2em)

This PDF was generated using Highlights.jl with Typst output.
Each section shows the same code in different themes and languages.

#v(1em)

#heading(level: 2)[Dracula]
#v(0.5em)

#text(weight: "bold")[Julia]
#block(fill: luma(245), inset: 8pt, radius: 4pt, width: 100%)[
#block(fill: rgb(40, 42, 54), inset: 1em, radius: 4pt, width: 100%)[
#set text(font: "DejaVu Sans Mono", size: 9pt, fill: rgb(248, 248, 242))
#set par(leading: 0.5em)
#text(fill: rgb(122, 122, 122))[#raw("# Fibonacci sequence")] \
#text(fill: rgb(230, 71, 71))[#raw("function")]#raw(" ")#text(fill: rgb(155, 107, 223))[#raw("fib")]#text(fill: rgb(248, 248, 242))[#raw("(")]#text(fill: rgb(248, 248, 242))[#raw("n")]#text(fill: rgb(248, 248, 242))[#raw("::")]#text(fill: rgb(117, 215, 236))[#raw("Int")]#text(fill: rgb(248, 248, 242))[#raw(")")] \
#raw("    ")#text(fill: rgb(248, 248, 242))[#raw("n")]#raw(" ")#text(fill: rgb(248, 248, 242))[#raw("<=")]#raw(" ")#text(fill: rgb(228, 243, 74))[#raw("1")]#raw(" ")#text(fill: rgb(248, 248, 242))[#raw("&&")]#raw(" ")#text(fill: rgb(230, 71, 71))[#raw("return")]#raw(" ")#text(fill: rgb(248, 248, 242))[#raw("n")] \
#raw("    ")#text(fill: rgb(230, 71, 71))[#raw("return")]#raw(" ")#text(fill: rgb(155, 107, 223))[#raw("fib")]#text(fill: rgb(248, 248, 242))[#raw("(")]#text(fill: rgb(248, 248, 242))[#raw("n")]#raw(" ")#text(fill: rgb(248, 248, 242))[#raw("-")]#raw(" ")#text(fill: rgb(228, 243, 74))[#raw("1")]#text(fill: rgb(248, 248, 242))[#raw(")")]#raw(" ")#text(fill: rgb(248, 248, 242))[#raw("+")]#raw(" ")#text(fill: rgb(155, 107, 223))[#raw("fib")]#text(fill: rgb(248, 248, 242))[#raw("(")]#text(fill: rgb(248, 248, 242))[#raw("n")]#raw(" ")#text(fill: rgb(248, 248, 242))[#raw("-")]#raw(" ")#text(fill: rgb(228, 243, 74))[#raw("2")]#text(fill: rgb(248, 248, 242))[#raw(")")] \
#text(fill: rgb(230, 71, 71))[#raw("end")] \
 \
#text(fill: rgb(155, 107, 223))[#raw("println")]#text(fill: rgb(248, 248, 242))[#raw("(")]#text(fill: rgb(66, 230, 108))[#raw("\"fib(10) = ")]#text(fill: rgb(248, 248, 242))[#raw("$")]#text(fill: rgb(248, 248, 242))[#raw("(")]#text(fill: rgb(155, 107, 223))[#raw("fib")]#text(fill: rgb(248, 248, 242))[#raw("(")]#text(fill: rgb(228, 243, 74))[#raw("10")]#text(fill: rgb(248, 248, 242))[#raw(")")]#text(fill: rgb(248, 248, 242))[#raw(")")]#text(fill: rgb(66, 230, 108))[#raw("\"")]#text(fill: rgb(248, 248, 242))[#raw(")")] \
]
]
#v(0.5em)

#text(weight: "bold")[Python]
#block(fill: luma(245), inset: 8pt, radius: 4pt, width: 100%)[
#block(fill: rgb(40, 42, 54), inset: 1em, radius: 4pt, width: 100%)[
#set text(font: "DejaVu Sans Mono", size: 9pt, fill: rgb(248, 248, 242))
#set par(leading: 0.5em)
#text(fill: rgb(122, 122, 122))[#raw("# Fibonacci sequence")] \
#text(fill: rgb(230, 71, 71))[#raw("def")]#raw(" ")#text(fill: rgb(155, 107, 223))[#raw("fib")]#raw("(")#text(fill: rgb(248, 248, 242))[#raw("n")]#raw("):") \
#raw("    ")#text(fill: rgb(230, 71, 71))[#raw("if")]#raw(" ")#text(fill: rgb(248, 248, 242))[#raw("n")]#raw(" ")#text(fill: rgb(248, 248, 242))[#raw("<=")]#raw(" ")#text(fill: rgb(228, 243, 74))[#raw("1")]#raw(":") \
#raw("        ")#text(fill: rgb(230, 71, 71))[#raw("return")]#raw(" ")#text(fill: rgb(248, 248, 242))[#raw("n")] \
#raw("    ")#text(fill: rgb(230, 71, 71))[#raw("return")]#raw(" ")#text(fill: rgb(155, 107, 223))[#raw("fib")]#raw("(")#text(fill: rgb(248, 248, 242))[#raw("n")]#raw(" ")#text(fill: rgb(248, 248, 242))[#raw("-")]#raw(" ")#text(fill: rgb(228, 243, 74))[#raw("1")]#raw(") ")#text(fill: rgb(248, 248, 242))[#raw("+")]#raw(" ")#text(fill: rgb(155, 107, 223))[#raw("fib")]#raw("(")#text(fill: rgb(248, 248, 242))[#raw("n")]#raw(" ")#text(fill: rgb(248, 248, 242))[#raw("-")]#raw(" ")#text(fill: rgb(228, 243, 74))[#raw("2")]#raw(")") \
 \
#text(fill: rgb(155, 107, 223))[#raw("print")]#raw("(")#text(fill: rgb(66, 230, 108))[#raw("f\"fib(10) = ")]#text(fill: rgb(248, 248, 242))[#raw("{")]#text(fill: rgb(155, 107, 223))[#raw("fib")]#text(fill: rgb(248, 248, 242))[#raw("(")]#text(fill: rgb(228, 243, 74))[#raw("10")]#text(fill: rgb(248, 248, 242))[#raw(")")]#text(fill: rgb(248, 248, 242))[#raw("}")]#text(fill: rgb(66, 230, 108))[#raw("\"")]#raw(")") \
]
]
#v(0.5em)

#text(weight: "bold")[Rust]
#block(fill: luma(245), inset: 8pt, radius: 4pt, width: 100%)[
#block(fill: rgb(40, 42, 54), inset: 1em, radius: 4pt, width: 100%)[
#set text(font: "DejaVu Sans Mono", size: 9pt, fill: rgb(248, 248, 242))
#set par(leading: 0.5em)
#text(fill: rgb(122, 122, 122))[#raw("// Fibonacci sequence")] \
#text(fill: rgb(230, 71, 71))[#raw("fn")]#raw(" ")#text(fill: rgb(155, 107, 223))[#raw("fib")]#text(fill: rgb(248, 248, 242))[#raw("(")]#text(fill: rgb(248, 248, 242))[#raw("n")]#text(fill: rgb(248, 248, 242))[#raw(":")]#raw(" ")#text(fill: rgb(139, 233, 253))[#raw("u32")]#text(fill: rgb(248, 248, 242))[#raw(")")]#raw(" -> ")#text(fill: rgb(139, 233, 253))[#raw("u32")]#raw(" ")#text(fill: rgb(248, 248, 242))[#raw("{")] \
#raw("    ")#text(fill: rgb(230, 71, 71))[#raw("if")]#raw(" n <= ")#text(fill: rgb(241, 250, 140))[#raw("1")]#raw(" ")#text(fill: rgb(248, 248, 242))[#raw("{")]#raw(" ")#text(fill: rgb(230, 71, 71))[#raw("return")]#raw(" n")#text(fill: rgb(248, 248, 242))[#raw(";")]#raw(" ")#text(fill: rgb(248, 248, 242))[#raw("}")] \
#raw("    ")#text(fill: rgb(155, 107, 223))[#raw("fib")]#text(fill: rgb(248, 248, 242))[#raw("(")]#raw("n - ")#text(fill: rgb(241, 250, 140))[#raw("1")]#text(fill: rgb(248, 248, 242))[#raw(")")]#raw(" + ")#text(fill: rgb(155, 107, 223))[#raw("fib")]#text(fill: rgb(248, 248, 242))[#raw("(")]#raw("n - ")#text(fill: rgb(241, 250, 140))[#raw("2")]#text(fill: rgb(248, 248, 242))[#raw(")")] \
#text(fill: rgb(248, 248, 242))[#raw("}")] \
 \
#text(fill: rgb(230, 71, 71))[#raw("fn")]#raw(" ")#text(fill: rgb(155, 107, 223))[#raw("main")]#text(fill: rgb(248, 248, 242))[#raw("(")]#text(fill: rgb(248, 248, 242))[#raw(")")]#raw(" ")#text(fill: rgb(248, 248, 242))[#raw("{")] \
#raw("    ")#text(fill: rgb(227, 86, 167))[#raw("println")]#text(fill: rgb(227, 86, 167))[#raw("!")]#text(fill: rgb(248, 248, 242))[#raw("(")]#text(fill: rgb(66, 230, 108))[#raw("\"fib(10) = {}\"")]#text(fill: rgb(248, 248, 242))[#raw(",")]#raw(" fib")#text(fill: rgb(248, 248, 242))[#raw("(")]#text(fill: rgb(241, 250, 140))[#raw("10")]#text(fill: rgb(248, 248, 242))[#raw(")")]#text(fill: rgb(248, 248, 242))[#raw(")")]#text(fill: rgb(248, 248, 242))[#raw(";")] \
#text(fill: rgb(248, 248, 242))[#raw("}")] \
]
]
#v(0.5em)

#pagebreak()
#heading(level: 2)[Nord]
#v(0.5em)

#text(weight: "bold")[Julia]
#block(fill: luma(245), inset: 8pt, radius: 4pt, width: 100%)[
#block(fill: rgb(46, 52, 64), inset: 1em, radius: 4pt, width: 100%)[
#set text(font: "DejaVu Sans Mono", size: 9pt, fill: rgb(216, 222, 233))
#set par(leading: 0.5em)
#text(fill: rgb(76, 86, 106))[#raw("# Fibonacci sequence")] \
#text(fill: rgb(191, 97, 106))[#raw("function")]#raw(" ")#text(fill: rgb(129, 161, 193))[#raw("fib")]#text(fill: rgb(229, 233, 240))[#raw("(")]#text(fill: rgb(229, 233, 240))[#raw("n")]#text(fill: rgb(229, 233, 240))[#raw("::")]#text(fill: rgb(136, 192, 208))[#raw("Int")]#text(fill: rgb(229, 233, 240))[#raw(")")] \
#raw("    ")#text(fill: rgb(229, 233, 240))[#raw("n")]#raw(" ")#text(fill: rgb(229, 233, 240))[#raw("<=")]#raw(" ")#text(fill: rgb(235, 203, 139))[#raw("1")]#raw(" ")#text(fill: rgb(229, 233, 240))[#raw("&&")]#raw(" ")#text(fill: rgb(191, 97, 106))[#raw("return")]#raw(" ")#text(fill: rgb(229, 233, 240))[#raw("n")] \
#raw("    ")#text(fill: rgb(191, 97, 106))[#raw("return")]#raw(" ")#text(fill: rgb(129, 161, 193))[#raw("fib")]#text(fill: rgb(229, 233, 240))[#raw("(")]#text(fill: rgb(229, 233, 240))[#raw("n")]#raw(" ")#text(fill: rgb(229, 233, 240))[#raw("-")]#raw(" ")#text(fill: rgb(235, 203, 139))[#raw("1")]#text(fill: rgb(229, 233, 240))[#raw(")")]#raw(" ")#text(fill: rgb(229, 233, 240))[#raw("+")]#raw(" ")#text(fill: rgb(129, 161, 193))[#raw("fib")]#text(fill: rgb(229, 233, 240))[#raw("(")]#text(fill: rgb(229, 233, 240))[#raw("n")]#raw(" ")#text(fill: rgb(229, 233, 240))[#raw("-")]#raw(" ")#text(fill: rgb(235, 203, 139))[#raw("2")]#text(fill: rgb(229, 233, 240))[#raw(")")] \
#text(fill: rgb(191, 97, 106))[#raw("end")] \
 \
#text(fill: rgb(129, 161, 193))[#raw("println")]#text(fill: rgb(229, 233, 240))[#raw("(")]#text(fill: rgb(163, 190, 140))[#raw("\"fib(10) = ")]#text(fill: rgb(229, 233, 240))[#raw("$")]#text(fill: rgb(229, 233, 240))[#raw("(")]#text(fill: rgb(129, 161, 193))[#raw("fib")]#text(fill: rgb(229, 233, 240))[#raw("(")]#text(fill: rgb(235, 203, 139))[#raw("10")]#text(fill: rgb(229, 233, 240))[#raw(")")]#text(fill: rgb(229, 233, 240))[#raw(")")]#text(fill: rgb(163, 190, 140))[#raw("\"")]#text(fill: rgb(229, 233, 240))[#raw(")")] \
]
]
#v(0.5em)

#text(weight: "bold")[Python]
#block(fill: luma(245), inset: 8pt, radius: 4pt, width: 100%)[
#block(fill: rgb(46, 52, 64), inset: 1em, radius: 4pt, width: 100%)[
#set text(font: "DejaVu Sans Mono", size: 9pt, fill: rgb(216, 222, 233))
#set par(leading: 0.5em)
#text(fill: rgb(76, 86, 106))[#raw("# Fibonacci sequence")] \
#text(fill: rgb(191, 97, 106))[#raw("def")]#raw(" ")#text(fill: rgb(129, 161, 193))[#raw("fib")]#raw("(")#text(fill: rgb(229, 233, 240))[#raw("n")]#raw("):") \
#raw("    ")#text(fill: rgb(191, 97, 106))[#raw("if")]#raw(" ")#text(fill: rgb(229, 233, 240))[#raw("n")]#raw(" ")#text(fill: rgb(229, 233, 240))[#raw("<=")]#raw(" ")#text(fill: rgb(235, 203, 139))[#raw("1")]#raw(":") \
#raw("        ")#text(fill: rgb(191, 97, 106))[#raw("return")]#raw(" ")#text(fill: rgb(229, 233, 240))[#raw("n")] \
#raw("    ")#text(fill: rgb(191, 97, 106))[#raw("return")]#raw(" ")#text(fill: rgb(129, 161, 193))[#raw("fib")]#raw("(")#text(fill: rgb(229, 233, 240))[#raw("n")]#raw(" ")#text(fill: rgb(229, 233, 240))[#raw("-")]#raw(" ")#text(fill: rgb(235, 203, 139))[#raw("1")]#raw(") ")#text(fill: rgb(229, 233, 240))[#raw("+")]#raw(" ")#text(fill: rgb(129, 161, 193))[#raw("fib")]#raw("(")#text(fill: rgb(229, 233, 240))[#raw("n")]#raw(" ")#text(fill: rgb(229, 233, 240))[#raw("-")]#raw(" ")#text(fill: rgb(235, 203, 139))[#raw("2")]#raw(")") \
 \
#text(fill: rgb(129, 161, 193))[#raw("print")]#raw("(")#text(fill: rgb(163, 190, 140))[#raw("f\"fib(10) = ")]#text(fill: rgb(229, 233, 240))[#raw("{")]#text(fill: rgb(129, 161, 193))[#raw("fib")]#text(fill: rgb(229, 233, 240))[#raw("(")]#text(fill: rgb(235, 203, 139))[#raw("10")]#text(fill: rgb(229, 233, 240))[#raw(")")]#text(fill: rgb(229, 233, 240))[#raw("}")]#text(fill: rgb(163, 190, 140))[#raw("\"")]#raw(")") \
]
]
#v(0.5em)

#text(weight: "bold")[Rust]
#block(fill: luma(245), inset: 8pt, radius: 4pt, width: 100%)[
#block(fill: rgb(46, 52, 64), inset: 1em, radius: 4pt, width: 100%)[
#set text(font: "DejaVu Sans Mono", size: 9pt, fill: rgb(216, 222, 233))
#set par(leading: 0.5em)
#text(fill: rgb(76, 86, 106))[#raw("// Fibonacci sequence")] \
#text(fill: rgb(191, 97, 106))[#raw("fn")]#raw(" ")#text(fill: rgb(129, 161, 193))[#raw("fib")]#text(fill: rgb(229, 233, 240))[#raw("(")]#text(fill: rgb(229, 233, 240))[#raw("n")]#text(fill: rgb(229, 233, 240))[#raw(":")]#raw(" ")#text(fill: rgb(143, 188, 187))[#raw("u32")]#text(fill: rgb(229, 233, 240))[#raw(")")]#raw(" -> ")#text(fill: rgb(143, 188, 187))[#raw("u32")]#raw(" ")#text(fill: rgb(229, 233, 240))[#raw("{")] \
#raw("    ")#text(fill: rgb(191, 97, 106))[#raw("if")]#raw(" n <= ")#text(fill: rgb(235, 203, 139))[#raw("1")]#raw(" ")#text(fill: rgb(229, 233, 240))[#raw("{")]#raw(" ")#text(fill: rgb(191, 97, 106))[#raw("return")]#raw(" n")#text(fill: rgb(229, 233, 240))[#raw(";")]#raw(" ")#text(fill: rgb(229, 233, 240))[#raw("}")] \
#raw("    ")#text(fill: rgb(129, 161, 193))[#raw("fib")]#text(fill: rgb(229, 233, 240))[#raw("(")]#raw("n - ")#text(fill: rgb(235, 203, 139))[#raw("1")]#text(fill: rgb(229, 233, 240))[#raw(")")]#raw(" + ")#text(fill: rgb(129, 161, 193))[#raw("fib")]#text(fill: rgb(229, 233, 240))[#raw("(")]#raw("n - ")#text(fill: rgb(235, 203, 139))[#raw("2")]#text(fill: rgb(229, 233, 240))[#raw(")")] \
#text(fill: rgb(229, 233, 240))[#raw("}")] \
 \
#text(fill: rgb(191, 97, 106))[#raw("fn")]#raw(" ")#text(fill: rgb(129, 161, 193))[#raw("main")]#text(fill: rgb(229, 233, 240))[#raw("(")]#text(fill: rgb(229, 233, 240))[#raw(")")]#raw(" ")#text(fill: rgb(229, 233, 240))[#raw("{")] \
#raw("    ")#text(fill: rgb(180, 142, 173))[#raw("println")]#text(fill: rgb(180, 142, 173))[#raw("!")]#text(fill: rgb(229, 233, 240))[#raw("(")]#text(fill: rgb(163, 190, 140))[#raw("\"fib(10) = {}\"")]#text(fill: rgb(229, 233, 240))[#raw(",")]#raw(" fib")#text(fill: rgb(229, 233, 240))[#raw("(")]#text(fill: rgb(235, 203, 139))[#raw("10")]#text(fill: rgb(229, 233, 240))[#raw(")")]#text(fill: rgb(229, 233, 240))[#raw(")")]#text(fill: rgb(229, 233, 240))[#raw(";")] \
#text(fill: rgb(229, 233, 240))[#raw("}")] \
]
]
#v(0.5em)

#pagebreak()
#heading(level: 2)[Solarized Light]
#v(0.5em)

#text(weight: "bold")[Julia]
#block(fill: luma(245), inset: 8pt, radius: 4pt, width: 100%)[
#block(fill: rgb(253, 246, 227), inset: 1em, radius: 4pt, width: 100%)[
#set text(font: "DejaVu Sans Mono", size: 9pt, fill: rgb(101, 123, 131))
#set par(leading: 0.5em)
#text(fill: rgb(101, 123, 131))[#raw("# Fibonacci sequence")] \
#text(fill: rgb(220, 50, 47))[#raw("function")]#raw(" ")#text(fill: rgb(38, 139, 210))[#raw("fib")]#text(fill: rgb(0, 43, 54))[#raw("(")]#text(fill: rgb(0, 43, 54))[#raw("n")]#text(fill: rgb(0, 43, 54))[#raw("::")]#text(fill: rgb(42, 161, 152))[#raw("Int")]#text(fill: rgb(0, 43, 54))[#raw(")")] \
#raw("    ")#text(fill: rgb(0, 43, 54))[#raw("n")]#raw(" ")#text(fill: rgb(0, 43, 54))[#raw("<=")]#raw(" ")#text(fill: rgb(181, 137, 0))[#raw("1")]#raw(" ")#text(fill: rgb(0, 43, 54))[#raw("&&")]#raw(" ")#text(fill: rgb(220, 50, 47))[#raw("return")]#raw(" ")#text(fill: rgb(0, 43, 54))[#raw("n")] \
#raw("    ")#text(fill: rgb(220, 50, 47))[#raw("return")]#raw(" ")#text(fill: rgb(38, 139, 210))[#raw("fib")]#text(fill: rgb(0, 43, 54))[#raw("(")]#text(fill: rgb(0, 43, 54))[#raw("n")]#raw(" ")#text(fill: rgb(0, 43, 54))[#raw("-")]#raw(" ")#text(fill: rgb(181, 137, 0))[#raw("1")]#text(fill: rgb(0, 43, 54))[#raw(")")]#raw(" ")#text(fill: rgb(0, 43, 54))[#raw("+")]#raw(" ")#text(fill: rgb(38, 139, 210))[#raw("fib")]#text(fill: rgb(0, 43, 54))[#raw("(")]#text(fill: rgb(0, 43, 54))[#raw("n")]#raw(" ")#text(fill: rgb(0, 43, 54))[#raw("-")]#raw(" ")#text(fill: rgb(181, 137, 0))[#raw("2")]#text(fill: rgb(0, 43, 54))[#raw(")")] \
#text(fill: rgb(220, 50, 47))[#raw("end")] \
 \
#text(fill: rgb(38, 139, 210))[#raw("println")]#text(fill: rgb(0, 43, 54))[#raw("(")]#text(fill: rgb(133, 153, 0))[#raw("\"fib(10) = ")]#text(fill: rgb(0, 43, 54))[#raw("$")]#text(fill: rgb(0, 43, 54))[#raw("(")]#text(fill: rgb(38, 139, 210))[#raw("fib")]#text(fill: rgb(0, 43, 54))[#raw("(")]#text(fill: rgb(181, 137, 0))[#raw("10")]#text(fill: rgb(0, 43, 54))[#raw(")")]#text(fill: rgb(0, 43, 54))[#raw(")")]#text(fill: rgb(133, 153, 0))[#raw("\"")]#text(fill: rgb(0, 43, 54))[#raw(")")] \
]
]
#v(0.5em)

#text(weight: "bold")[Python]
#block(fill: luma(245), inset: 8pt, radius: 4pt, width: 100%)[
#block(fill: rgb(253, 246, 227), inset: 1em, radius: 4pt, width: 100%)[
#set text(font: "DejaVu Sans Mono", size: 9pt, fill: rgb(101, 123, 131))
#set par(leading: 0.5em)
#text(fill: rgb(101, 123, 131))[#raw("# Fibonacci sequence")] \
#text(fill: rgb(220, 50, 47))[#raw("def")]#raw(" ")#text(fill: rgb(38, 139, 210))[#raw("fib")]#raw("(")#text(fill: rgb(0, 43, 54))[#raw("n")]#raw("):") \
#raw("    ")#text(fill: rgb(220, 50, 47))[#raw("if")]#raw(" ")#text(fill: rgb(0, 43, 54))[#raw("n")]#raw(" ")#text(fill: rgb(0, 43, 54))[#raw("<=")]#raw(" ")#text(fill: rgb(181, 137, 0))[#raw("1")]#raw(":") \
#raw("        ")#text(fill: rgb(220, 50, 47))[#raw("return")]#raw(" ")#text(fill: rgb(0, 43, 54))[#raw("n")] \
#raw("    ")#text(fill: rgb(220, 50, 47))[#raw("return")]#raw(" ")#text(fill: rgb(38, 139, 210))[#raw("fib")]#raw("(")#text(fill: rgb(0, 43, 54))[#raw("n")]#raw(" ")#text(fill: rgb(0, 43, 54))[#raw("-")]#raw(" ")#text(fill: rgb(181, 137, 0))[#raw("1")]#raw(") ")#text(fill: rgb(0, 43, 54))[#raw("+")]#raw(" ")#text(fill: rgb(38, 139, 210))[#raw("fib")]#raw("(")#text(fill: rgb(0, 43, 54))[#raw("n")]#raw(" ")#text(fill: rgb(0, 43, 54))[#raw("-")]#raw(" ")#text(fill: rgb(181, 137, 0))[#raw("2")]#raw(")") \
 \
#text(fill: rgb(38, 139, 210))[#raw("print")]#raw("(")#text(fill: rgb(133, 153, 0))[#raw("f\"fib(10) = ")]#text(fill: rgb(0, 43, 54))[#raw("{")]#text(fill: rgb(38, 139, 210))[#raw("fib")]#text(fill: rgb(0, 43, 54))[#raw("(")]#text(fill: rgb(181, 137, 0))[#raw("10")]#text(fill: rgb(0, 43, 54))[#raw(")")]#text(fill: rgb(0, 43, 54))[#raw("}")]#text(fill: rgb(133, 153, 0))[#raw("\"")]#raw(")") \
]
]
#v(0.5em)

#text(weight: "bold")[Rust]
#block(fill: luma(245), inset: 8pt, radius: 4pt, width: 100%)[
#block(fill: rgb(253, 246, 227), inset: 1em, radius: 4pt, width: 100%)[
#set text(font: "DejaVu Sans Mono", size: 9pt, fill: rgb(101, 123, 131))
#set par(leading: 0.5em)
#text(fill: rgb(101, 123, 131))[#raw("// Fibonacci sequence")] \
#text(fill: rgb(220, 50, 47))[#raw("fn")]#raw(" ")#text(fill: rgb(38, 139, 210))[#raw("fib")]#text(fill: rgb(0, 43, 54))[#raw("(")]#text(fill: rgb(0, 43, 54))[#raw("n")]#text(fill: rgb(0, 43, 54))[#raw(":")]#raw(" ")#text(fill: rgb(42, 161, 152))[#raw("u32")]#text(fill: rgb(0, 43, 54))[#raw(")")]#raw(" -> ")#text(fill: rgb(42, 161, 152))[#raw("u32")]#raw(" ")#text(fill: rgb(0, 43, 54))[#raw("{")] \
#raw("    ")#text(fill: rgb(220, 50, 47))[#raw("if")]#raw(" n <= ")#text(fill: rgb(181, 137, 0))[#raw("1")]#raw(" ")#text(fill: rgb(0, 43, 54))[#raw("{")]#raw(" ")#text(fill: rgb(220, 50, 47))[#raw("return")]#raw(" n")#text(fill: rgb(0, 43, 54))[#raw(";")]#raw(" ")#text(fill: rgb(0, 43, 54))[#raw("}")] \
#raw("    ")#text(fill: rgb(38, 139, 210))[#raw("fib")]#text(fill: rgb(0, 43, 54))[#raw("(")]#raw("n - ")#text(fill: rgb(181, 137, 0))[#raw("1")]#text(fill: rgb(0, 43, 54))[#raw(")")]#raw(" + ")#text(fill: rgb(38, 139, 210))[#raw("fib")]#text(fill: rgb(0, 43, 54))[#raw("(")]#raw("n - ")#text(fill: rgb(181, 137, 0))[#raw("2")]#text(fill: rgb(0, 43, 54))[#raw(")")] \
#text(fill: rgb(0, 43, 54))[#raw("}")] \
 \
#text(fill: rgb(220, 50, 47))[#raw("fn")]#raw(" ")#text(fill: rgb(38, 139, 210))[#raw("main")]#text(fill: rgb(0, 43, 54))[#raw("(")]#text(fill: rgb(0, 43, 54))[#raw(")")]#raw(" ")#text(fill: rgb(0, 43, 54))[#raw("{")] \
#raw("    ")#text(fill: rgb(211, 54, 130))[#raw("println")]#text(fill: rgb(211, 54, 130))[#raw("!")]#text(fill: rgb(0, 43, 54))[#raw("(")]#text(fill: rgb(133, 153, 0))[#raw("\"fib(10) = {}\"")]#text(fill: rgb(0, 43, 54))[#raw(",")]#raw(" fib")#text(fill: rgb(0, 43, 54))[#raw("(")]#text(fill: rgb(181, 137, 0))[#raw("10")]#text(fill: rgb(0, 43, 54))[#raw(")")]#text(fill: rgb(0, 43, 54))[#raw(")")]#text(fill: rgb(0, 43, 54))[#raw(";")] \
#text(fill: rgb(0, 43, 54))[#raw("}")] \
]
]
#v(0.5em)

#pagebreak()
#heading(level: 2)[Gruvbox Dark]
#v(0.5em)

#text(weight: "bold")[Julia]
#block(fill: luma(245), inset: 8pt, radius: 4pt, width: 100%)[
#block(fill: rgb(40, 40, 40), inset: 1em, radius: 4pt, width: 100%)[
#set text(font: "DejaVu Sans Mono", size: 9pt, fill: rgb(235, 219, 178))
#set par(leading: 0.5em)
#text(fill: rgb(146, 131, 116))[#raw("# Fibonacci sequence")] \
#text(fill: rgb(204, 36, 29))[#raw("function")]#raw(" ")#text(fill: rgb(69, 133, 136))[#raw("fib")]#text(fill: rgb(168, 153, 132))[#raw("(")]#text(fill: rgb(168, 153, 132))[#raw("n")]#text(fill: rgb(168, 153, 132))[#raw("::")]#text(fill: rgb(104, 157, 106))[#raw("Int")]#text(fill: rgb(168, 153, 132))[#raw(")")] \
#raw("    ")#text(fill: rgb(168, 153, 132))[#raw("n")]#raw(" ")#text(fill: rgb(168, 153, 132))[#raw("<=")]#raw(" ")#text(fill: rgb(215, 153, 33))[#raw("1")]#raw(" ")#text(fill: rgb(168, 153, 132))[#raw("&&")]#raw(" ")#text(fill: rgb(204, 36, 29))[#raw("return")]#raw(" ")#text(fill: rgb(168, 153, 132))[#raw("n")] \
#raw("    ")#text(fill: rgb(204, 36, 29))[#raw("return")]#raw(" ")#text(fill: rgb(69, 133, 136))[#raw("fib")]#text(fill: rgb(168, 153, 132))[#raw("(")]#text(fill: rgb(168, 153, 132))[#raw("n")]#raw(" ")#text(fill: rgb(168, 153, 132))[#raw("-")]#raw(" ")#text(fill: rgb(215, 153, 33))[#raw("1")]#text(fill: rgb(168, 153, 132))[#raw(")")]#raw(" ")#text(fill: rgb(168, 153, 132))[#raw("+")]#raw(" ")#text(fill: rgb(69, 133, 136))[#raw("fib")]#text(fill: rgb(168, 153, 132))[#raw("(")]#text(fill: rgb(168, 153, 132))[#raw("n")]#raw(" ")#text(fill: rgb(168, 153, 132))[#raw("-")]#raw(" ")#text(fill: rgb(215, 153, 33))[#raw("2")]#text(fill: rgb(168, 153, 132))[#raw(")")] \
#text(fill: rgb(204, 36, 29))[#raw("end")] \
 \
#text(fill: rgb(69, 133, 136))[#raw("println")]#text(fill: rgb(168, 153, 132))[#raw("(")]#text(fill: rgb(152, 151, 26))[#raw("\"fib(10) = ")]#text(fill: rgb(168, 153, 132))[#raw("$")]#text(fill: rgb(168, 153, 132))[#raw("(")]#text(fill: rgb(69, 133, 136))[#raw("fib")]#text(fill: rgb(168, 153, 132))[#raw("(")]#text(fill: rgb(215, 153, 33))[#raw("10")]#text(fill: rgb(168, 153, 132))[#raw(")")]#text(fill: rgb(168, 153, 132))[#raw(")")]#text(fill: rgb(152, 151, 26))[#raw("\"")]#text(fill: rgb(168, 153, 132))[#raw(")")] \
]
]
#v(0.5em)

#text(weight: "bold")[Python]
#block(fill: luma(245), inset: 8pt, radius: 4pt, width: 100%)[
#block(fill: rgb(40, 40, 40), inset: 1em, radius: 4pt, width: 100%)[
#set text(font: "DejaVu Sans Mono", size: 9pt, fill: rgb(235, 219, 178))
#set par(leading: 0.5em)
#text(fill: rgb(146, 131, 116))[#raw("# Fibonacci sequence")] \
#text(fill: rgb(204, 36, 29))[#raw("def")]#raw(" ")#text(fill: rgb(69, 133, 136))[#raw("fib")]#raw("(")#text(fill: rgb(168, 153, 132))[#raw("n")]#raw("):") \
#raw("    ")#text(fill: rgb(204, 36, 29))[#raw("if")]#raw(" ")#text(fill: rgb(168, 153, 132))[#raw("n")]#raw(" ")#text(fill: rgb(168, 153, 132))[#raw("<=")]#raw(" ")#text(fill: rgb(215, 153, 33))[#raw("1")]#raw(":") \
#raw("        ")#text(fill: rgb(204, 36, 29))[#raw("return")]#raw(" ")#text(fill: rgb(168, 153, 132))[#raw("n")] \
#raw("    ")#text(fill: rgb(204, 36, 29))[#raw("return")]#raw(" ")#text(fill: rgb(69, 133, 136))[#raw("fib")]#raw("(")#text(fill: rgb(168, 153, 132))[#raw("n")]#raw(" ")#text(fill: rgb(168, 153, 132))[#raw("-")]#raw(" ")#text(fill: rgb(215, 153, 33))[#raw("1")]#raw(") ")#text(fill: rgb(168, 153, 132))[#raw("+")]#raw(" ")#text(fill: rgb(69, 133, 136))[#raw("fib")]#raw("(")#text(fill: rgb(168, 153, 132))[#raw("n")]#raw(" ")#text(fill: rgb(168, 153, 132))[#raw("-")]#raw(" ")#text(fill: rgb(215, 153, 33))[#raw("2")]#raw(")") \
 \
#text(fill: rgb(69, 133, 136))[#raw("print")]#raw("(")#text(fill: rgb(152, 151, 26))[#raw("f\"fib(10) = ")]#text(fill: rgb(168, 153, 132))[#raw("{")]#text(fill: rgb(69, 133, 136))[#raw("fib")]#text(fill: rgb(168, 153, 132))[#raw("(")]#text(fill: rgb(215, 153, 33))[#raw("10")]#text(fill: rgb(168, 153, 132))[#raw(")")]#text(fill: rgb(168, 153, 132))[#raw("}")]#text(fill: rgb(152, 151, 26))[#raw("\"")]#raw(")") \
]
]
#v(0.5em)

#text(weight: "bold")[Rust]
#block(fill: luma(245), inset: 8pt, radius: 4pt, width: 100%)[
#block(fill: rgb(40, 40, 40), inset: 1em, radius: 4pt, width: 100%)[
#set text(font: "DejaVu Sans Mono", size: 9pt, fill: rgb(235, 219, 178))
#set par(leading: 0.5em)
#text(fill: rgb(146, 131, 116))[#raw("// Fibonacci sequence")] \
#text(fill: rgb(204, 36, 29))[#raw("fn")]#raw(" ")#text(fill: rgb(69, 133, 136))[#raw("fib")]#text(fill: rgb(168, 153, 132))[#raw("(")]#text(fill: rgb(168, 153, 132))[#raw("n")]#text(fill: rgb(168, 153, 132))[#raw(":")]#raw(" ")#text(fill: rgb(142, 192, 124))[#raw("u32")]#text(fill: rgb(168, 153, 132))[#raw(")")]#raw(" -> ")#text(fill: rgb(142, 192, 124))[#raw("u32")]#raw(" ")#text(fill: rgb(168, 153, 132))[#raw("{")] \
#raw("    ")#text(fill: rgb(204, 36, 29))[#raw("if")]#raw(" n <= ")#text(fill: rgb(250, 189, 47))[#raw("1")]#raw(" ")#text(fill: rgb(168, 153, 132))[#raw("{")]#raw(" ")#text(fill: rgb(204, 36, 29))[#raw("return")]#raw(" n")#text(fill: rgb(168, 153, 132))[#raw(";")]#raw(" ")#text(fill: rgb(168, 153, 132))[#raw("}")] \
#raw("    ")#text(fill: rgb(69, 133, 136))[#raw("fib")]#text(fill: rgb(168, 153, 132))[#raw("(")]#raw("n - ")#text(fill: rgb(250, 189, 47))[#raw("1")]#text(fill: rgb(168, 153, 132))[#raw(")")]#raw(" + ")#text(fill: rgb(69, 133, 136))[#raw("fib")]#text(fill: rgb(168, 153, 132))[#raw("(")]#raw("n - ")#text(fill: rgb(250, 189, 47))[#raw("2")]#text(fill: rgb(168, 153, 132))[#raw(")")] \
#text(fill: rgb(168, 153, 132))[#raw("}")] \
 \
#text(fill: rgb(204, 36, 29))[#raw("fn")]#raw(" ")#text(fill: rgb(69, 133, 136))[#raw("main")]#text(fill: rgb(168, 153, 132))[#raw("(")]#text(fill: rgb(168, 153, 132))[#raw(")")]#raw(" ")#text(fill: rgb(168, 153, 132))[#raw("{")] \
#raw("    ")#text(fill: rgb(177, 98, 134))[#raw("println")]#text(fill: rgb(177, 98, 134))[#raw("!")]#text(fill: rgb(168, 153, 132))[#raw("(")]#text(fill: rgb(152, 151, 26))[#raw("\"fib(10) = {}\"")]#text(fill: rgb(168, 153, 132))[#raw(",")]#raw(" fib")#text(fill: rgb(168, 153, 132))[#raw("(")]#text(fill: rgb(250, 189, 47))[#raw("10")]#text(fill: rgb(168, 153, 132))[#raw(")")]#text(fill: rgb(168, 153, 132))[#raw(")")]#text(fill: rgb(168, 153, 132))[#raw(";")] \
#text(fill: rgb(168, 153, 132))[#raw("}")] \
]
]
#v(0.5em)

#pagebreak()
