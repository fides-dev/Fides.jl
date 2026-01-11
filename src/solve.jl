"""
    FidesSolution

Solution information from a Fides optmization run.

## Fields
- `xmin`: Minimizing parameter vector found by the optimization rung
- `fmin`: Minimum objective value found by the optimization run
- `niterations`: Number of iterations for the optimization run
- `runtime`: Runtime in seconds for the optimization run
- `retcode`: Return code from the optimization run. Possible values are:
    - `DELTA_TOO_SMALL`: Trust Region Radius too small to proceed
    - `DID_NOT_RUN`: Optimizer did not run
    - `EXCEEDED_BOUNDARY`: Exceeded specified boundaries
    - `FTOL`: Converged according to fval difference
    - `GTOL`: Converged according to gradient norm
    - `XTOL`: Converged according to x difference
    - `MAXITER`: Reached maximum number of allowed iterations
    - `MAXTIME`: Reached maximum runtime
    - `NOT_FINITE`: Encountered non-finite fval/grad/hess
"""
struct FidesSolution
    fmin::Float64
    xmin::Vector{Float64}
    niterations::Int64
    runtime::Float64
    retcode::Symbol
end

"""
    solve(prob::FidesProblem, hess_update; options = FidesOptions())

Solve the given `FidesProblem` using the Fides Trust Region method, with the specified
`hess_update` method for computing the Hessian matrix.

In case a custom Hessian is provided to `prob`, use `hess_update = Fides.CustomHessian`.
Otherwise, a Hessian approximation must be provided, and a complete list of available
approximations can be found in the
[API](https://fides-dev.github.io/Fides.jl/stable/API/) documentation.

See also [FidesOptions](@ref).
"""
function solve(
        prob::FidesProblem, hess_update::HessianUpdate; options::FidesOptions = FidesOptions()
    )::FidesSolution
    if prob.user_hessian == false && hess_update isa CustomHessian
        throw(ArgumentError("\
            The FidesProblem does not have a user provided Hessian. In this case \
            solve(prob Fides.HessianApproximation; kwargs...) should be called. Not solve \
            solve(prob Fides.CustomHessian; kwargs...) A complete list of Hessian \
            approximations can be found in the API documentation"))
    end
    if prob.user_hessian == true && !(hess_update isa CustomHessian)
        throw(ArgumentError("\
            The FidesProblem has a user provided Hessian. In this case \
            solve(prob Fides.CustomHessian(); kwargs...) should be called. Not solve \
            with a Hessian approximation (e.g. Fides.BFGS()) method"))
    end
    return _solve(prob, hess_update, options)
end

function _solve(
        prob::FidesProblem, hess_update::HessianUpdate, options::FidesOptions
    )::FidesSolution
    @unpack fides_objective_py, lb, ub = prob
    verbose_py = _get_verbose_py(options.verbose_level)
    options_py = _fides_options(options)
    if !(hess_update isa CustomHessian)
        hess_update_py = _get_hess_update_py(hess_update)
        fides_opt_py = fides_py.Optimizer(
            fides_objective_py, np_py.asarray(ub), np_py.asarray(lb), options = options_py,
            hessian_update = hess_update_py, verbose = verbose_py
        )
    else
        fides_opt_py = fides_py.Optimizer(
            fides_objective_py, np_py.asarray(ub), np_py.asarray(lb), options = options_py,
            verbose = verbose_py
        )
    end

    if hess_update isa CustomHessian || hess_update.init_with_hess == false
        runtime = @elapsed begin
            res = fides_opt_py.minimize(np_py.asarray(prob.x0))
        end
        # An initialization Hessian has been provided by the user
    else
        hess_init_py = _get_hess_init_py(hess_update)
        runtime = @elapsed begin
            res = fides_opt_py.minimize(np_py.asarray(prob.x0), hess0 = hess_init_py)
        end
    end
    return FidesSolution(
        PythonCall.pyconvert(Float64, res[0]),
        PythonCall.pyconvert(Vector{Float64}, res[1]),
        PythonCall.pyconvert(Int64, fides_opt_py.iteration), runtime,
        PythonCall.pyconvert(Symbol, fides_opt_py.exitflag._name_)
    )
end

function _get_hess_update_py(hess_update::Union{BB, BG, SR1})
    if hess_update isa BB
        return hess_update_py = fides_py.BB()
    elseif hess_update isa BG
        return hess_update_py = fides_py.BG()
    elseif hess_update isa SR1
        return hess_update_py = fides_py.SR1()
    end
end
function _get_hess_update_py(hess_update::Union{BFGS, DFP})
    enforce_curv_cond = hess_update.enforce_curv_cond
    if hess_update isa BFGS
        return hess_update_py = fides_py.BFGS(enforce_curv_cond = enforce_curv_cond)
    elseif hess_update isa DFP
        return hess_update_py = fides_py.DFP(enforce_curv_cond = enforce_curv_cond)
    end
end
function _get_hess_update_py(hess_update::Broyden)
    @unpack phi, enforce_curv_cond = hess_update
    return fides_py.Broyden(phi = phi, enforce_curv_cond = enforce_curv_cond)
end

function _get_hess_init_py(hess_update::HessianApproximation)
    @assert hess_update.init_with_hess == true "Function for user provided Hessian \
        called even though Hessian not provided. Please report as bug on GitHub"
    return np_py.array(hess_update.init_hess)
end

function _get_init_with_hess(init_hess)::Bool
    return !isnothing(init_hess)
end
