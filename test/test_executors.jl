# Copied from
# https://github.com/JuliaFolds/FLoops.jl/blob/master/test/test_executors.jl
# (for now).  TODO: Create FLoopsTesting.jl so that writing something
# like this easier?
module TestExecutors

using FLoops
using DaggerFolds
using Test

function f_sum(executor)
    @floop executor for x in 1:10
        @reduce(s += x)
    end
    return s
end

function f_filter_sum(executor)
    @floop executor for x in 1:10
        if isodd(x)
            @reduce(s += x)
        end
    end
    return s
end

function f_sum_nested_loop(executor)
    @floop executor for x in 1:10
        for y in 1:x
            @reduce(s += y)
        end
    end
    return s
end

function f_sum_update(executor)
    @floop executor for x in 1:10
        if isodd(x)
            @reduce(s += 2x)
        end
    end
    return s
end

function f_sum_op_init(executor)
    @floop executor for x in 1:10
        if isodd(x)
            @reduce(s = 0 + 2x)
        end
    end
    return s
end

function f_count_update(executor)
    @floop executor for x in 1:10
        if isodd(x)
            @reduce(s += 1)
        end
    end
    return s
end

function f_count_op_init(executor)
    @floop executor for x in 1:10
        if isodd(x)
            @reduce(s = 0 + 1)
        end
    end
    return s
end

function f_sum_continue(executor)
    @floop executor for x in 1:10
        x > 4 && continue
        @reduce(s += x)
    end
    return s
end

function f_sum_break(executor)
    @floop executor for x in 1:10
        @reduce(s += x)
        x == 3 && break
    end
    return s
end

function f_find_return(executor)
    @floop executor for x in 1:10
        @reduce(s += x)
        x == 3 && return (:found, x)
    end
    return s
end

function f_find_goto(executor)
    @floop executor for x in 1:10
        @reduce() do (s; x)
            s = x
        end
        x == 3 && @goto FOUND
    end
    return s
    @label FOUND
    return (:found, s)
end

@testset "$f" for (f, desired) in [
    (f_sum, 55),
    (f_filter_sum, 25),
    (f_sum_nested_loop, 220),
    (f_sum_update, 50),
    (f_sum_op_init, 50),
    (f_count_update, 5),
    (f_count_op_init, 5),
    (f_sum_continue, 10),
    (f_sum_break, 6),
    (f_find_return, (:found, 3)),
    (f_find_goto, (:found, 3)),
]
    @test f(SequentialEx()) === desired
    @test f(DaggerEx()) === desired
    @testset for basesize in 2:10
        @test f(DaggerEx(basesize = 2)) === desired
    end
end

end  # module
