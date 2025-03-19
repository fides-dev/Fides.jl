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
    solve(prob::FidesProblem, hess_approximation; options = FidesOptions())

Solve the given `FidesProblem` using the Fides Trust Region method, with the specified
`hess_approximation` to approximate the Hessian matrix.

A complete list of available Hessian approximations is provided in the documentation.

See also [FidesOptions](@ref).
"""
function solve(prob::FidesProblem, hess_approximation::HessianUpdate; options::FidesOptions = FidesOptions())::FidesSolution
    @unpack fides_objective_py, lb, ub, user_hessian = prob
    if user_hessian == true
        throw(ArgumentError("\
            The FidesProblem has a user provided Hessian. In this case solve(prob; kwargs...)
            should be called. Not solve(prob, hess_approximation; kwargs....) as a Hessian \
            is not needed"))
    end
    return _solve(prob, hess_approximation, options)
end
"""
    solve(prob::FidesProblem; options = FidesOptions())

Solve the optimization problem `prob` with the Fides Trust region method with the user
provided Hessian in `prob`.
"""
function solve(prob::FidesProblem; options::FidesOptions = FidesOptions())::FidesSolution
    if prob.user_hessian == false
        throw(ArgumentError("\
            The FidesProblem does not have a user provided Hessian. In this case
            solve(prob, hess_approximation; kwargs....) should be called as a Hessian \
            approximation is needed"))
    end
    return _solve(prob, nothing, options)
end

function _solve(prob::FidesProblem, hess_approximation::Union{HessianUpdate, Nothing}, options::FidesOptions)::FidesSolution
    @unpack fides_objective_py, lb, ub = prob
    verbose_py = _get_verbose_py(options.verbose_level)
    options_py = _fides_options(options)
    if !isnothing(hess_approximation)
        hess_approximation_py = _get_hess_approximation_py(hess_approximation)
        fides_opt_py = fides_py.Optimizer(fides_objective_py, np_py.asarray(ub), np_py.asarray(lb), options = options_py, hessian_update = hess_approximation_py, verbose = verbose_py)
    else
        fides_opt_py = fides_py.Optimizer(fides_objective_py, np_py.asarray(ub), np_py.asarray(lb), options = options_py, verbose = verbose_py)
    end
    runtime = @elapsed begin
        res = fides_opt_py.minimize(np_py.asarray(prob.x0))
    end
    return FidesSolution(pyconvert(Float64, res[0]), pyconvert(Vector{Float64}, res[1]), pyconvert(Int64, fides_opt_py.iteration), runtime, pyconvert(Symbol, fides_opt_py.exitflag._name_))
end

function _get_hess_approximation_py(hess_approximation::HessianUpdate)
    hess_approximation_py = _get_hess_method(hess_approximation)
    _init_hess!(hess_approximation_py, hess_approximation.init_hess)
    return hess_approximation_py
end

function _get_hess_method(hess_approximation::Union{BB, BG, SR1})
    if hess_approximation isa BB
        return hess_approximation_py = fides_py.BB(init_with_hess = hess_approximation.init_with_hess)
    elseif hess_approximation isa BG
        return hess_approximation_py = fides_py.BG(init_with_hess = hess_approximation.init_with_hess)
    elseif hess_approximation isa SR1
        return hess_approximation_py = fides_py.SR1(init_with_hess = hess_approximation.init_with_hess)
    end
end
function _get_hess_method(hess_approximation::Union{BFGS, DFP})
    @unpack init_with_hess, enforce_curv_cond, init_hess = hess_approximation
    if hess_approximation isa BFGS
        return hess_approximation_py = fides_py.BFGS(init_with_hess = init_with_hess, enforce_curv_cond = enforce_curv_cond)
    elseif hess_approximation isa DFP
        return hess_approximation_py = fides_py.DFP(init_with_hess = init_with_hess, enforce_curv_cond = enforce_curv_cond)
    end
end
function _get_hess_method(hess_approximation::Broyden)
    @unpack phi, init_with_hess, enforce_curv_cond, init_hess = hess_approximation
    return fides_py.Broyden(phi = phi, init_with_hess = init_with_hess, enforce_curv_cond = enforce_curv_cond)
end

function _init_hess!(hess_approximation_py, init_hess)::Nothing
    isnothing(init_hess) && return nothing
    dim = size(init_hess)[1]
    init_hess_py = np_py.array(init_hess)
    hess_approximation_py.init_mat(dim, init_hess_py)
    return nothing
end

function _get_init_with_hess(init_hess)::Bool
    return !isnothing(init_hess)
end
