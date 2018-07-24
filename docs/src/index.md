# Highlights.jl

*A source code highlighter for Julia.*

## Introduction

This package provides a collection of source code *lexers* for various languages and markup
formats and a selection of *themes* that can be used to customise the style of the formatted
source code. Additional *lexer* definitions are straightforward to add and are based on the
regular expression lexing mechanism used by [Pygments](http://pygments.org/).

## Installation

`Highlights` is a registered package and so can be installed via

```julia
Pkg.add("Highlights")
```

The package has no dependencies other than Julia (`0.7` and up) itself.

## Usage

  * See the [User Guide](@ref) for an introduction to using the package;
  * the [Theme Guide](@ref) will explain how to add new themes;
  * and the [Lexer Guide](@ref) will walk you through writing new lexer definitions.
