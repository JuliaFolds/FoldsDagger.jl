struct DAZip{A,M}
    arrays::A  # a tuple of arrays of chunks
    mappers::M  # a tuple functions
end

preprocess_darray(rf, xs::AbstractArray) = preprocess_darray(Map(first)'(rf), zip(xs))

function preprocess_darray(rf, xs::Iterators.Zip)
    da = nothing
    for it in xs.is
        if it isa ReferenceableArray
            it = it.x
        end
        if it isa DArray
            da = it
            break
        end
    end
    da === nothing && return nothing, nothing
    blocks = map(last, first(da.subdomains).indexes) # find a better way
    arrays = map(xs.is) do it
        if it isa DArray
            it
        elseif it isa ReferenceableArray
            it.x isa DArray || error("`ReferenceableArray` must wrap `DArray`")
            it.x
        else
            distribute(it, blocks)
        end
    end
    all(it.subdomains == da.subdomains for it in arrays) ||
        error("unequal chunking not implemented yet")

    mappers = map(xs.is) do it
        if it isa ReferenceableArray{<:Any,<:Any,<:DArray}
            referenceable
        else
            identity
        end
    end

    return (rf, DAZip(arrays, mappers))
end

function _reduce_basecase_zip(rf, init, mappers, chunks...)
    iters = map(|>, chunks, mappers)
    return _reduce_basecase(rf, init, zip(iters...))
end

function _transduce_darray(rf, init, xs::DAZip, _basesize)
    # TODO: further divide each chunk into `basesize`
    mappers = xs.mappers
    f(chunks) = delayed(_reduce_basecase_zip)(rf, init, mappers, chunks...)
    op(a, b) = delayed(_combine)(rf, a, b)
    return _mapreduce(f, op, init, zip((A.chunks for A in xs.arrays)...))
end
