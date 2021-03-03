module TestReferenceables

using Dagger
using FLoops
using FoldsDagger
using Referenceables
using Test

function test_in_place_module()
    xs = distribute(collect(1:4), Blocks(2))
    @floop DaggerEx() for x in referenceable(xs)
        x[] += 1
    end
    @test collect(xs) == 2:5
end

function test_copy()
    xs = distribute(1:4, Blocks(2))
    ys = distribute(zeros(4), Blocks(2))
    @floop DaggerEx() for (y, x) in zip(referenceable(ys), xs)
        y[] = x
    end
    @test collect(ys) == 1:4
end

function test_fan_out()
    xs = distribute(1:4, Blocks(2))
    ys = distribute(zeros(4), Blocks(2))
    zs = distribute(zeros(4), Blocks(2))
    @floop DaggerEx() for (z, y, x) in zip(referenceable(zs), referenceable(ys), xs)
        y[] = x
        z[] = 2x
    end
    @test collect(ys) == 1:4
    @test collect(zs) == 2:2:8
end

end
