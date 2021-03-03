module TestDArray

using Dagger
using FLoops
using Folds
using FoldsDagger
using Test

function test_1d()
    @testset for n in 1:4
        A = distribute(1:4, Blocks(n))
        @test foldx_dagger(+, A) == sum(1:4)
        @test Folds.sum(A) == sum(1:4)
    end
end

function test_2d()
    @testset for n in 1:4, m in 1:3
        A = distribute(reshape(1:24, (4, 6)), Blocks(n, m))
        @test foldx_dagger(+, A) == sum(1:24)
        @test Folds.sum(A) == sum(1:24)
    end
end

end
