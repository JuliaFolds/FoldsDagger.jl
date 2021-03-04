module FoldsDagger

export DaggerEx, foldx_dagger, transduce_dagger

using Dagger: DArray, delayed, distribute
using SplittablesBase: amount, halve
using Referenceables: ReferenceableArray, referenceable
using Transducers:
    Executor,
    Map,
    Reduced,
    Transducer,
    Transducers,
    combine,
    complete,
    foldl_nocomplete,
    reduced,
    start,
    unreduced

# TODO: Don't import internals from Transducers:
using Transducers:
    DefaultInit,
    DefaultInitOf,
    EmptyResultError,
    IdentityTransducer,
    maybe_usesimd,
    restack,
    retransform

include("core.jl")
include("darray.jl")

end
