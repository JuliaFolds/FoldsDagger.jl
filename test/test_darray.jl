module TestDArray

using Dagger
using FLoops
using FoldsDagger
using Test

@testset "1d" begin
    @testset for n in 1:4
        A = distribute(1:4, Blocks(n))
        @test foldx_dagger(+, A) == sum(1:4)
    end
end

@testset "2d" begin
    @testset for n in 1:4, m in 1:3
        A = distribute(reshape(1:24, (4, 6)), Blocks(n, m))
        @test foldx_dagger(+, A) == sum(1:24)
    end
end

end
