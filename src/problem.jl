"""
    FidesProblem(f, grad!, x0; hess! = nothing, lb = nothing, ub = nothing)

Construct an optimization problem to be minimized with the Fides Newton Trust Region
optimizer.

## Arguments
- `f`: The objective function to minimize. It should accept a vector as input and return a
    scalar.
- `grad!`: An in-place function to compute the gradient of `f` on the form `grad!(g, x)`.
- `x0`: The initial starting point for the optimization.
- `hess!`: (Optional) An in-place function to compute the Hessian of `f` on the form
    `hess!(H, x)`.  If not provided, a Hessian approximation method must be selected when
    calling `solve`.
- `lb`: The lower bounds for the parameters. Defaults to `-Inf` if not specified.
- `ub`: The upper bounds for the parameters. Defaults to `Inf` if not specified.

See also [solve](@ref) and [FidesOptions](@ref).

## Description of Fides method

Fides implements an Interior Trust Region Reflective method for boundary-constrained
optimization, as described in [1, 2]. Briefly, it tries to solve:

```math
\\min_x f(x) \\quad \\text{s.t.} \\quad lb \\leq x \\leq ub
```

In particular, at each iteration, the Newton Trust Region method approximates the objective
function with a second-order approximation:

```math
\\min_x m_k(x) = f(x_k) + \\nabla f(x_k)^T (x - x_k) + 0.5 (x - x_k)^T B_k (x - x_k)
\\quad \\text{s.t.} \\quad \\|x - x_k\\| \\leq \\Delta_k
```

Where `Δₖ` is the trust region radius, `∇f(xₖ)` is the gradient of `f` at the current
iterate and `Bₖ` is a symmetric positive-semidefinite matrix, which can be the exact
Hessian (if `hess!` is provided), otherwise an approximation can be used.

Fides provides various tuning options; while the default settings are generally effective,
a complete list can be found in [FidesOptions](@ref).
"""
struct FidesProblem{T <: AbstractVector}
    fides_objective::Function
    fides_objective_py::Function
    x0::T
    lb::T
    ub::T
    user_hessian::Bool
end
function FidesProblem(f::Function, grad!::Function, x0::AbstractVector; hess! = nothing, lb = nothing, ub = nothing)
    _lb = _get_bounds(x0, lb, :lower)
    _ub = _get_bounds(x0, ub, :upper)
    fides_objective = _get_fides_objective(f, grad!, hess!, false)
    fides_objective_py = _get_fides_objective(f, grad!, hess!, true)
    user_hessian = !isnothing(hess!)
    return FidesProblem(fides_objective, fides_objective_py, x0, _lb, _ub, user_hessian)
end

function _get_fides_objective(f::Function, grad!::Function, hess!::Union{Function, Nothing}, py::Bool)::Function
    if !isnothing(hess!)
        fides_objective = (x) -> let _grad! = grad!, _f = f, _hess! = hess!, _py = py
            return _fides_objective(x, _f, _grad!, _hess!, _py)
        end
    else
        fides_objective = (x) -> let _grad! = grad!, _f = f, _py = py
            return _fides_objective(x, _f, _grad!, _py)
        end
    end
    return fides_objective
end

function _fides_objective(x, f::Function, grad!::Function, py::Bool)
    _x = py ? PythonCall.pyconvert(Vector{Float64}, x) : x
    obj = f(_x)
    g = _grad_fides(_x, grad!)
    if py
        return (obj, np_py.array(g))
    else
        return (obj, g)
    end
end
function _fides_objective(x, f::Function, grad!::Function, hess!::Function, py::Bool)
    _x = py ? PythonCall.pyconvert(Vector{Float64}, x) : x
    obj = f(_x)
    g = _grad_fides(_x, grad!)
    H = _hess_fides(_x, hess!)
    if py
        return (obj, np_py.array(g), np_py.array(H))
    else
        return (obj, g, H)
    end
end

# Fides requires out-of-place gradients and Hessian
function _grad_fides(x::AbstractVector, grad!::Function)
    g = similar(x)
    grad!(g, x)
    return g
end

function _hess_fides(x::T, hess!::Function)::T where T <: AbstractVector
    H = similar(x, (length(x), length(x)))
    hess!(H, x)
    return H
end

function _get_bounds(x0::AbstractVector, bound::Union{AbstractVector, Nothing}, which_bound::Symbol)::AbstractVector
    @assert which_bound in [:lower, :upper] "Only lower and upper bounds are supported"
    !isnothing(bound) && return bound
    _bound = similar(x0)
    if which_bound === :lower
        fill!(_bound, -Inf)
    else
        fill!(_bound, Inf)
    end
    return _bound
end
