# This file is a part of Julia. License is MIT: https://julialang.org/license

"""
    Null

A type with no fields that is the type [`null`](@ref).
"""
struct Null end

"""
    null

The singleton instance of type [`Null`](@ref), used to denote a missing value.
"""
const null = Null()

"""
    Some{T}

A wrapper type used with [`Option`](@ref) (a.k.a. `Union{Null, Some{T}}`). Its main
purposes are to force handling the possibility of the `Option` being [`null`](@ref)
by calling [`unwrap`](@ref) (with [`isnull`](@ref)) before actually using the wrapped
value; and to allow distinguishing `null` from `Some(null)` when an `Option` may wrap
a `null` value.
"""
struct Some{T}
    value::T
end

"""
    Option{T}

A type alias for `Union{Null, Some{T}}` used to hold either a value of type `T` inside
a [`Some`](@ref) wrapper, or a [`null`](@ref) value. Use [`isnull`](@ref) to check whether
an `Option` object is null, and [`unwrap`](@ref) to access the value inside the `Some`
object if not.
"""
Option{T} = Union{Null, Some{T}}

eltype(::Type{Some{T}}) where {T} = T

promote_rule(::Type{Some{S}}, ::Type{Some{T}}) where {S,T} = Some{promote_type(S, T)}
promote_rule(::Type{Some{T}}, ::Type{Null}) where {T} = Option{T}

convert(::Type{Some{T}}, x::Some) where {T} = Some{T}(convert(T, x.value))

convert(::Type{Null}, ::Null) = null
convert(::Type{Null}, ::Void) = null
convert(::Type{Null}, ::Any) = throw(NullException())

convert(::Type{Option{T}}, ::Null) where {T} = null
convert(::Type{Option   }, ::Null)           = null
# FIXME: find out why removing these two methods makes addprocs() fail
convert(::Type{Option{T}}, ::Void) where {T} = null
convert(::Type{Option}, ::Void) = null

convert(::Type{Option{T}}, x::Some) where {T} = convert(Some{T}, x)

show(io::IO, ::Null) = print(io, "null")

function show(io::IO, x::Some)
    if get(io, :compact, false)
        show(io, x.value)
    else
        print(io, "Some(")
        show(io, x.value)
        print(io, ')')
    end
end

"""
    NullException()

[`null`](@ref) was found in a context where it is not accepted.
"""
struct NullException <: Exception
end

"""
    isnull(x)

Return whether or not `x` is `null`.
"""
isnull(x) = false
isnull(::Null) = true

"""
    unwrap(x::Option[, y])

Attempt to access the value of `x`. Returns the value if `x` is not [`null`](@ref),
otherwise, returns `y` if provided, or throws a `NullException` if not.

# Examples
```jldoctest
julia> unwrap(Some(5))
5

julia> unwrap(null)
ERROR: NullException()
[...]

julia> unwrap(Some(1), 0)
1

julia> unwrap(null, 0)
0

```
"""
function unwrap end

unwrap(x::Some) = x.value
unwrap(::Null) = throw(NullException())

unwrap(x::Some, y) = x.value
unwrap(x::Null, y) = y
