if get(ENV, "CI", "false") == "true"
    using Distributed
    let n = 2
        if nprocs() < n
            addprocs(n - nprocs())
        end
    end
end

using TestFunctionRunner
TestFunctionRunner.@run
