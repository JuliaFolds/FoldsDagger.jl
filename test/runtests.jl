module TestFoldsDagger
using Distributed: addprocs, nprocs
using Test

if get(ENV, "CI", "false") == "true"
    addprocs(1)
end
@info "Testing with:" nprocs()

@testset "$file" for file in sort([
    file for file in readdir(@__DIR__) if match(r"^test_.*\.jl$", file) !== nothing
])
    include(file)
end
end  # module
