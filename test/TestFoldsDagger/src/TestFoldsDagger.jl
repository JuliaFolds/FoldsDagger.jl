module TestFoldsDagger

using Test

for file in readdir(@__DIR__)
    if match(r"^test_.*\.jl$", file) !== nothing
        include(joinpath(@__DIR__, file))
    end
end

end # module
