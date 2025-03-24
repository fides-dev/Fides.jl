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

## Hessian Approximations

In cases where the Hessian is too expensive or difficult to compute, several Hessian approximations are supported. The BFGS method is often effective:

```@docs
Fides.BFGS
Fides.SR1
Fides.DFP
Fides.Broyden
Fides.BG
Fides.BB
```
