preprocess_darray(rf, xs::DArray) = Map(first)'(rf), zip(xs)

function preprocess_darray(rf, xs::Zip)
    da = nothing
    for it in xs.is
        if it isa DArray
            da = it
            break
        end
    end
    da === nothing && return nothing, nothing
    blocks = map(last, fist(da.subindices)) # find a better way
    arrays = map(xs.is) do it
        if it isa DArray
            it
        else
            distribute(it, blocks)
        end
    end
    all(it.subindices == da.subindices for it in xs.is) ||
        error("unequal chunking not implemented yet")

    rf, zip(arrays...)
end

_reduce_basecase_zip(rf, init, chunks...) = _reduce_basecase(rf, init, zip(chunks...))

function _transduce_darray(rf, init, xs::Zip, _basesize)
    # TODO: further divide each chunk into `basesize`
    f(chunks) = delayed(_reduce_basecase_zip)(rf, init, chunks...)
    op(a, b) = delayed(_combine)(rf, a, b)
    return _mapreduce(f, op, init, zip((it.chunks for it in xs.is)...))
end
