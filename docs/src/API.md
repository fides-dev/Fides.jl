```@meta
CollapsedDocStrings=true
```

# [API](@id API)

## FidesProblem

To solve an optimization problem with Fides, a `FidesProblem` must first be created:

```@docs
FidesProblem
```

Thereafter, the `FidesProblem` is solved using the `solve` function, which accepts numerous tuning options:

```@docs
solve
FidesOptions
```

Results are stored in a `FidesSolution` struct:

```@docs
Fides.FidesSolution
```

## Hessian Options

Multiple Hessian options and approximation methods are available. When the Hessian is too costly or difficult to compute, the `BFGS` method is often performant:

```@docs
Fides.CustomHessian
Fides.BFGS
Fides.SR1
Fides.DFP
Fides.Broyden
Fides.BG
Fides.BB
```
