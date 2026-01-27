# Fibonacci with memoization
module Fib

const cache = Dict{Int,BigInt}()

"""Calculate the nth Fibonacci number."""
function fib(n::Int)::BigInt
    n <= 1 && return BigInt(n)
    get!(cache, n) do
        fib(n - 1) + fib(n - 2)
    end
end

for i = 1:10
    Base.println("fib($i) = $(fib(i))")
end

# Demonstrate qualified calls
Base.length(cache)
Core.typeof(cache)
Base.Iterators.take(1:10, 3)

end # module

#=
Additional syntax coverage from old julia sample:
Nested comments #= can be #= deeply =# nested =#
=#

# Array and tuple literals
[1, 3, 3, 4][1:end]
(1, 2, 1.0)[1:2]
[(1, 3), (3, 4)][end-1]
[(1, 3), (3, 4)][begin]

# Control flow
if x in y
    nothing
end
x in y ? false : true

let x = 1
    local t
    global s
    t = x
end

# Type definitions
abstract type AbstractPoint{T} <: Number end
mutable struct Point{T} where {T<:Number}
    x::T
    y::T
    Point(x) = new(x, 2x)
end
struct Empty{T} end
primitive type Float16Custom <: AbstractFloat 16 end

# Macros
macro something(x...)
    nothing
end

# Character literals
' ', '\n', '\'', '"', '\u1234', '⻆'

# String literals
"""Multiline
string"""
" $x $(let x = y + 1; x^2; end) "
r"[a-z]+$xyz"m
raw"\n\n\r\t...\b"
v"0.0.2" ≥ v"0.0.1"

# Command literals
`echo $bar`

# Number formats
1_000_000 + 1.0e-9 * 0.121 / 1121.0
1.0f0 - 1E-12
0b100_101_111
0o12123535
0x4312afAF
