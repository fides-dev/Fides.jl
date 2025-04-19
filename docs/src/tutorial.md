# Tutorial

This overarching tutorial describes how to solve an optimization problem with Fides. It further provides performance tips for computationally intensive objective functions.

## Input - a Function to Minimize

Fides requires a function to minimize, its gradient and optionally its Hessian. In this tutorial, we use the nonlinear Rosenbrock function:

```math
f(x_1, x_2) = (1.0 - x_1)^2 + 100.0(x_2 - x_1^2)^2
```

The objective function is expected to take a vector input  and return a scalar:

```@example 1
function f(x)
    return (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2
end
nothing # hide
```

Where `x` may be either a `Vector` or a `ComponentVector` from [ComponentArrays.jl](https://github.com/SciML/ComponentArrays.jl). Fides also requires a gradient function, and optionally a Hessian function. In this example, for convenience we compute both via automatic differentiation using [ForwardDiff.jl](https://github.com/JuliaDiff/ForwardDiff.jl):

```@example 1
using ForwardDiff
grad! = (g, x) -> ForwardDiff.gradient!(g, f, x)
hess! = (H, x) -> ForwardDiff.hessian!(H, f, x)
nothing # hide
```

Both the gradient and Hessian functions are expected to be in-place on the form; `grad!(g, x)` and `hess!(H, x)`.

## Optimization with a Hessian Approximation

Given an objective function and its gradient, the optimization is performed in a two-step procedure. First, a `FidesProblem` is created.

```@example 1
using Fides
lb = [-2.0, -2.0]
ub = [ 2.0,  2.0]
x0 = [ 2.0,  2.0]
prob = FidesProblem(f, grad!, x0; lb = lb, ub = ub)
```

Where `x0` is the initial guess for parameter estimation, and `lb` and `ub` are the lower and upper parameter bounds (defaulting to `-Inf` and `Inf` if unspecified). The problem is then minimized by calling `solve`. When the Hessian is unavailable or too expensive to compute, a Hessian approximation is provided during this step:

```@example 1
sol = solve(prob, Fides.BFGS()) # hide
sol = solve(prob, Fides.BFGS())
```

Several Hessian approximations are supported (see the [API](@ref API)), and `BFGS` generally performs well. Additional tuning options can be set by providing a [`FidesOptions`](@ref) struct via the `options` keyword in `solve`, and a full list of available options can be found in the [API](@ref API) documentation.

## Optimization with a User-Provided Hessian

If the Hessian (or a suitable approximation such as the [Gauss–Newton approximation](https://en.wikipedia.org/wiki/Gauss%E2%80%93Newton_algorithm)) is available, providing it can improve convergence. To provide a Hessian function to `FidesProblem` do:

```@example 1
prob = FidesProblem(f, grad!, x0; hess! = hess!, lb = lb, ub = ub)
nothing # hide
```

Then, when solving the problem use the `Fides.CustomHessian()` Hessian option:

```@example 1
sol = solve(prob, Fides.CustomHessian()) # hide
sol = solve(prob, Fides.CustomHessian())
```

## Performance tip: Computing Derivatives and Objective Simultaneously

Internally, the objective function and its derivatives are computed simultaneously by Fides. Hence, runtime can be reduced if is is possible to reuse intermediate quantities between the objective and derivative computations. To take advantage of this, a `FidesProblem` can be created with a function that computes the objective and gradient (and optionally the Hessian) for a given input. For example, when only the gradient is available:

```@example 1
function fides_obj(x)
    obj = f(x)
    g   = ForwardDiff.gradient(f, x)
    return (obj, g)
end

prob = FidesProblem(fides_obj, x0; lb = lb, ub = ub)
sol = solve(prob, Fides.BFGS()) # hide
sol = solve(prob, Fides.BFGS())
```

When a Hessian function is available, do:

```@example 1
function fides_obj(x)
    obj = f(x)
    g   = ForwardDiff.gradient(f, x)
    H   = ForwardDiff.hessian(f, x)
    return (obj, g, H)
end

prob = FidesProblem(fides_obj, x0; lb = lb, ub = ub)
sol = solve(prob, Fides.CustomHessian()) # hide
sol = solve(prob, Fides.CustomHessian())
```

In this simple example, no runtime benefit is obtained as no quantities are reused between objective and derivative computations. However, if quantities can be reused (for example, when gradients are computed for ODE models), runtime can be noticeably reduced.
