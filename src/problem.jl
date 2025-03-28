"""
    FidesProblem(f, grad!, x0; hess! = nothing, lb = nothing, ub = nothing)

Optimization problem to be minimized with the Fides Newton Trust Region optimizer.

## Arguments
- `f`: The objective function to minimize. Accepts a vector as input and return a scalar.
- `grad!`: In-place function to compute the gradient of `f` on the form `grad!(g, x)`.
- `x0`: Initial starting point for the optimization. Can be a `Vector` or `ComponentVector`
    from [ComponentArrays.jl](https://github.com/SciML/ComponentArrays.jl).
- `hess!`: (Optional) In-place function to compute the Hessian of `f` on the form
    `hess!(H, x)`. If not provided, a Hessian approximation method must be selected when
    calling `solve`.
- `lb`: Lower parameter bounds. Defaults to `-Inf` if not specified.
- `ub`: Upper parameter bounds. Defaults to `Inf` if not specified.

See also [solve](@ref) and [FidesOptions](@ref).

## Description of Fides method

Fides implements an Interior Trust Region Reflective method for boundary-constrained
optimization, as described in [1, 2]. Optimization problems on the following form are
targeted:

```math
\\min_x f(x) \\quad \\text{s.t.} \\quad lb \\leq x \\leq ub
```

At each iteration, the Fides approximates the objective function by a second-order model:

```math
\\min_x m_k(x) = f(x_k) + \\nabla f(x_k)^T (x - x_k) + 0.5 (x - x_k)^T B_k (x - x_k)
\\quad \\text{s.t.} \\quad |x - x_k| \\leq \\Delta_k
```

Where, `Δₖ` is the trust region radius reflecting the confidence in the second-order
approximation, `∇f(xₖ)` of `f` at the current iteration `xₖ`, and `Bₖ` is a symmetric
positive-semidefinite matrix, that is either the exact Hessian (if `hess!` is provided) or
an approximation.

## References
1. Coleman, T. F., & Li, Y. (1994). On the convergence of interior-reflective Newton
    methods for nonlinear minimization subject to bounds. Mathematical programming, 67(1),
    189-224.
2. Coleman, T. F., & Li, Y. (1996). An interior trust region approach for nonlinear
    minimization subject to bounds. SIAM Journal on optimization, 6(2), 418-445.
"""
struct FidesProblem{T <: AbstractVector}
    fides_objective::Function
    fides_objective_py::Function
    x0::T
    lb::T
    ub::T
    user_hessian::Bool
end
function FidesProblem(f::Function, grad!::Function, x0::InputVector; hess! = nothing,
                      lb = nothing, ub = nothing)
    _lb = _get_bounds(x0, lb, :lower)
    _ub = _get_bounds(x0, ub, :upper)
    # To ensure correct input type to f, grad!, hess! a variable having the same type as
    # x0 is needed when building the objective
    xinput = similar(x0)
    fides_objective = _get_fides_objective(f, grad!, hess!, xinput, false)
    fides_objective_py = _get_fides_objective(f, grad!, hess!, xinput, true)
    user_hessian = !isnothing(hess!)
    return FidesProblem(fides_objective, fides_objective_py, x0, _lb, _ub, user_hessian)
end
"""
    FidesProblem(fides_obj, x0, hess::Bool; lb = nothing, ub = nothing)

Optimization problem created from a function that computes:
- `hess = false`: Objective and gradient; `fides_obj(x) -> (obj, g)`.
- `hess = true`: Objective, gradient and Hessian; `fides_obj(x) -> (obj, g, H)`.

Internally, Fides computes the objective function and derivatives simultaneously. Therefore,
this constructor is the most runtime-efficient option when intermediate quantities can be
reused between the objective and derivative computations.
"""
function FidesProblem(fides_objective::Function, x0::InputVector, hess::Bool; lb = nothing,
                      ub = nothing)
    _lb = _get_bounds(x0, lb, :lower)
    _ub = _get_bounds(x0, ub, :upper)
    # See xinput comment above
    xinput = similar(x0)
    if hess == false
        fides_objective_py = _get_fides_objective(fides_objective, nothing, xinput, true)
    else
        fides_objective_py = _get_fides_objective(fides_objective, xinput, true)
    end
    return FidesProblem(fides_objective, fides_objective_py, x0, _lb, _ub, hess)
end

function _get_fides_objective(f::Function, grad!::Function, hess!::Union{Function, Nothing},
                              xinput::InputVector, py::Bool)::Function
    if !isnothing(hess!)
        fides_objective = (x) -> let _grad! = grad!, _f = f, _hess! = hess!,
            _xinput = xinput, _py = py

            return _fides_objective(x, _f, _grad!, _hess!, _xinput, _py)
        end
    else
        fides_objective = (x) -> let _grad! = grad!, _f = f, _xinput = xinput, _py = py
            return _fides_objective(x, _f, _grad!, _xinput, _py)
        end
    end
    return fides_objective
end
function _get_fides_objective(f_grad::Function, ::Nothing, xinput::InputVector,
                              py::Bool)::Function
    fides_objective = (x) -> let _f_grad = f_grad, _xinput = xinput, _py = py
        return _fides_objective(x, _f_grad, nothing, _xinput, _py)
    end
    return fides_objective
end
function _get_fides_objective(f_grad_hess::Function, xinput::InputVector,
                              py::Bool)::Function
    fides_objective = (x) -> let _f_grad_hess = f_grad_hess, _xinput = xinput, _py = py
        return _fides_objective(x, _f_grad_hess, _xinput, _py)
    end
    return fides_objective
end

function _fides_objective(x, f::Function, grad!::Function, xinput::InputVector, py::Bool)
    _get_xinput!(xinput, x)
    obj = f(xinput)
    g = _grad_fides(xinput, grad!)
    return _get_fides_results(obj, g, py)
end
function _fides_objective(x, f::Function, grad!::Function, hess!::Function,
                          xinput::InputVector, py::Bool)
    _get_xinput!(xinput, x)
    obj = f(xinput)
    g = _grad_fides(xinput, grad!)
    H = _hess_fides(xinput, hess!)
    return _get_fides_results(obj, g, H, py)
end
function _fides_objective(x, f_grad::Function, ::Nothing, xinput::InputVector, py::Bool)
    _get_xinput!(xinput, x)
    obj, g = f_grad(xinput)
    return _get_fides_results(obj, g, py)
end
function _fides_objective(x, f_grad_hess::Function, xinput::InputVector, py::Bool)
    _get_xinput!(xinput, x)
    obj, g, H = f_grad_hess(xinput)
    return _get_fides_results(obj, g, H, py)
end

# Fides requires out-of-place gradients and Hessian
function _grad_fides(x::InputVector, grad!::Function)
    g = similar(x)
    grad!(g, x)
    return g
end

function _hess_fides(x::InputVector, hess!::Function)::Matrix
    H = similar(x, (length(x), length(x)))
    hess!(H, x)
    return H
end

function _get_bounds(x0::InputVector, bound::Union{InputVector, Nothing},
                     which_bound::Symbol)::AbstractVector
    @assert which_bound in [:lower, :upper] "Only lower and upper bounds are supported"
    !isnothing(bound) && return bound
    _bound = similar(x0)
    _bound_value = which_bound === :lower ? -Inf : Inf
    fill!(_bound, _bound_value)
    return _bound
end

function _get_fides_results(obj::Float64, g::AbstractVector, H::AbstractMatrix, py::Bool)
    return py ? (obj, np_py.array(g), np_py.array(H)) : (obj, g, H)
end
function _get_fides_results(obj::Float64, g::AbstractVector, py::Bool)
    return py ? (obj, np_py.array(g)) : (obj, g)
end

function _get_xinput!(xinput::InputVector, x)::Nothing
    xinput .= x
    return nothing
end
