"""
    foldx_dagger(op[, xf], xs; init, simd, basesize)
    transduce_dagger(op[, xf], init, xs; simd, basesize)

Extended distributed fold backed up by Dagger.
"""
(foldx_dagger, transduce_dagger)

const SIMDFlag = Union{Bool,Symbol,Val{true},Val{false},Val{:ivdep}}

issmall(reducible, basesize) = amount(reducible) <= basesize

foldx_dagger(op, xs; init = DefaultInit, kwargs...) =
    Transducers.fold(op, xs, DaggerEx(; kwargs...); init = init)

foldx_dagger(op, xf, xs; kwargs...) = foldx_dagger(op, xf(xs); kwargs...)

transduce_dagger(xf::Transducer, op, init, xs; kwargs...) =
    transduce_dagger(xf'(op), init, xs; kwargs...)

preprocess_darray(_, _) = nothing, nothing

function transduce_dagger(
    rf0,
    init,
    xs0;
    simd::SIMDFlag = Val(false),
    basesize::Union{Integer,Nothing} = nothing,
)
    rf, xs = retransform(rf0, xs0)
    # TODO: replace Threads.nthreads() with the number of workers
    basesize = max(1, basesize === nothing ? amount(xs) ÷ Threads.nthreads() : basesize)
    rf′, xs′ = preprocess_darray(maybe_usesimd(rf, simd), xs)
    if xs′ !== nothing
        thunk = _transduce_darray(rf′, init, xs′, basesize)
    else
        thunk = _delayed_reduce(maybe_usesimd(rf, simd), init, xs, basesize)
    end
    acc = collect(thunk)
    result = complete(rf, acc)
    if unreduced(result) isa DefaultInitOf
        throw(EmptyResultError(rf))
    end
    return result
end

function _delayed_reduce(rf, init, xs, basesize)
    if amount(xs) <= basesize
        return delayed(_reduce_basecase)(rf, init, xs)
    end
    left, right = halve(xs)
    a = _delayed_reduce(rf, init, left, basesize)
    b = _delayed_reduce(rf, init, right, basesize)
    return delayed(_combine)(rf, a, b)
end

@noinline _reduce_basecase(rf::F, init::I, reducible) where {F,I} =
    restack(foldl_nocomplete(rf, start(rf, init), reducible))

# Semantically correct but inefficient (eager) handling of `Reduced`.
# Not sure how to cancel `delayed` computation.
_combine(rf, a::Reduced, b::Reduced) = a
_combine(rf, a::Reduced, b) = a
_combine(rf::RF, a, b::Reduced) where {RF} = reduced(combine(rf, a, unreduced(b)))
_combine(rf::RF, a, b) where {RF} = combine(rf, a, b)

_mapreduce(f, op, init, xs) =
    if length(xs) == 0
        start(op, init)
    elseif length(xs) == 1
        a, = xs
        f(a)
    elseif length(xs) == 2
        a, b = xs
        op(f(a), f(b))
    else
        left, right = halve(xs)
        a = _mapreduce(f, op, init, left)
        b = _mapreduce(f, op, init, right)
        op(a, b)
    end

"""
    DaggerEx(; simd, basesize) :: Transducers.Executor

Fold Executor implemented using Dagger.jl.
"""
struct DaggerEx{K} <: Executor
    kwargs::K
end

Transducers.transduce(xf, rf::RF, init, xs, exc::DaggerEx) where {RF} =
    transduce_dagger(xf, rf, init, xs; exc.kwargs...)
