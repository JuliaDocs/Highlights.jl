module Highlights

import Artifacts
import JSON
import Pkg
import TreeSitter

export highlight, stylesheet, Theme, Highlight

include("ansi.jl")
include("themes.jl")
include("languages.jl")
include("highlight.jl")
include("formats/ansi.jl")
include("formats/html.jl")
include("formats/latex.jl")
include("formats/plain.jl")
include("formats/typst.jl")
include("stylesheet.jl")
include("preprocessors.jl")
include("api.jl")
include("show.jl")

end
