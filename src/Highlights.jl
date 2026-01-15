module Highlights

import Artifacts
import JSON
import Pkg
import TreeSitter

export highlight, stylesheet, Theme

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

end
