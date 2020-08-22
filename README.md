# DaggerFolds

DaggerFolds.jl is a proof-of-concept package for
[Transducers.jl](https://github.com/JuliaFolds/Transducers.jl)-compatible
parallel fold (`foldx_dagger` and `transduce_dagger`) implemented
using [Dagger.jl](https://github.com/JuliaParallel/Dagger.jl)
framework.  It also provides
[FLoops.jl](https://github.com/JuliaFolds/FLoops.jl) executor
`DaggerEx`.  The result of fold implemented by DaggerFolds.jl is
deterministic and does not depend on a particular run-time scheduling.

Example:

```julia
julia> using DaggerFolds, FLoops

julia> @floop DaggerEx() for (i, v) in pairs([0, 1, 3, 2]), (j, w) in pairs([3, 1, 5])
           d = abs(v - w)
           @reduce() do (dmax = -1; d), (imax = 0; i), (jmax = 0; j)
               if isless(dmax, d)
                   dmax = d
                   imax = i
                   jmax = j
               end
           end
       end
       (dmax, imax, jmax)
(5, 1, 3)
```
