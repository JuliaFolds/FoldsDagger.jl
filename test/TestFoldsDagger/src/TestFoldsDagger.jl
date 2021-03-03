module TestFoldsDagger

using Distributed
using Test

for file in readdir(@__DIR__)
    if match(r"^test_.*\.jl$", file) !== nothing
        include(joinpath(@__DIR__, file))
    end
end

function collect_modules(root = @__MODULE__)
    modules = Module[]
    for n in names(root, all = true)
        m = getproperty(root, n)
        m isa Module || continue
        m === root && continue
        startswith(string(nameof(m)), "Test") || continue
        push!(modules, m)
    end
    return modules
end

function load_me_everywhere()
    pkgid = Base.PkgId(@__MODULE__)
    @everywhere Base.require($pkgid)
end

function runtests(modules = collect_modules())
    if get(ENV, "CI", "false") == "true"
        addprocs(1)
    end
    @info "Testing with:" nprocs()
    load_me_everywhere()

    @testset "$(nameof(m))" for m in modules
        tests = map(names(m, all = true)) do n
            startswith(string(n), "test_") || return nothing
            f = getproperty(m, n)
            f !== m || return nothing
            parentmodule(f) === m || return nothing
            applicable(f) || return nothing  # removed by Revise?
            return f
        end
        filter!(!isnothing, tests)
        @testset "$f" for f in tests
            f()
        end
    end
end

end # module
