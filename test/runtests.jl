if get(ENV, "CI", "false") == "true"
    const Pkg = Base.require(Base.PkgId(Base.UUID(0x44cfe95a1eb252eab672e2afdf69b78f), "Pkg"))
    Pkg.pkg"add TestFunctionRunner#fix-distributed"

    using Distributed
    let n = 2
        if nprocs() < n
            addprocs(n - nprocs())
        end
    end
end

using TestFunctionRunner
TestFunctionRunner.@run
