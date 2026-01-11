"""
    FidesOptions(; kwargs...)

Options for the Fides Optimizer.

## Keyword arguments
- `maxiter = 1000`: Maximum number of allowed iterations
- `fatol = 1e-8`: Absolute tolerance for convergence based on objective (f) value
- `frtol = 1e-8`: Relative tolerance for convergence based on objective (f) value
- `gatol = 1e-6`: Absolute tolerance for convergence based on the gradient
- `grtol = 0.0`: Relative tolerance for convergence based on the gradient
- `xtol = 0.0`: Tolerance for convergence based on `x` (parameter vector)
- `maxtime = Inf`: Maximum amount of wall-time in seconds
- `verbose`: The logging (verbosity) level of the optimizer. Allowed values are:
  - `warning` (default): Only warnings are printed.
  - `info`: Information is printed for each iterations.
  - `error`: Only errors are printed.
  - `debug`: Detailed information is printed, typically only of interest for developers.
- `stepback_strategy`: Refinement method if proposed step reaches optimization boundary.
    Allowed options are:
    - `reflect` (default): Recursive reflections at boundary
    - `refine`: Perform optimization to refine step
    - `reflect_single`: Single reflection at boundary
    - `mixed`: Mix reflections and truncations
    - `trunace`: Truncate step at boundary and re-solve
- `subspace_solver`: Subspace dimension in which the Trust region subproblem is solved.
    Allowed options are:
    - `2D` (default): Two dimensional Newton/Gradient subspace
    - `scg`: CG subspace via Steihaug’s method
    - `full`: Full on R^n
- `delta_init = 1.0`: Initial trust region radius
- `mu = 0.25`: Acceptance threshold for trust region ratio
- `eta = 0.75`: Trust region increase threshold for trust region ratio
- `theta_max = 0.95`: Maximal fraction of step that would hit bounds
- `gamma1 = 0.25`: Factor by which trust region radius will be decreased
- `gamma2 = 2.0`: Factor by which trust region radius will be increased
- `history_file = nothing`: Records statistics when set
"""
struct FidesOptions{T <: Union{String, Nothing}}
    maxiter::Int64
    fatol::Float64
    frtol::Float64
    gatol::Float64
    grtol::Float64
    xtol::Float64
    maxtime::Float64
    verbose_level::String
    stepback_strategy::String
    subspace_solver::String
    delta_init::Float64
    mu::Float64
    eta::Float64
    theta_max::Float64
    gamma1::Float64
    gamma2::Float64
    history_file::T
end
function FidesOptions(;
        maxiter::Integer = 1000, fatol::Float64 = 1.0e-8,
        frtol::Float64 = 1.0e-8, gatol::Float64 = 1.0e-6, grtol::Float64 = 0.0,
        xtol::Float64 = 0.0, maxtime::Float64 = Inf, verbose = "warning",
        subspace_solver::String = "2D", stepback_strategy::String = "reflect",
        delta_init::Float64 = 1.0, mu::Float64 = 0.25, eta::Float64 = 0.75,
        theta_max = 0.95, gamma1::Float64 = 0.25, gamma2::Float64 = 2.0,
        history_file = nothing
    )::FidesOptions
    if !(stepback_strategy in STEPBACK_STRATEGIES)
        throw(ArgumentError("$(stepback_strategy) is not a valid stepback strategy. \
            Valid options are $(STEPBACK_STRATEGIES)"))
    end
    if !(subspace_solver in SUBSPACE_SOLVERS)
        throw(ArgumentError("$(subspace_solver) is not a valid subspace solver. Valid \
            options are $(SUBSPACE_SOLVERS)"))
    end
    if !(verbose in LOGGING_LEVELS)
        throw(ArgumentError("$(verbose) is not a valid verbosity level solver. Valid \
            options are $(LOGGING_LEVELS)"))
    end

    return FidesOptions(
        maxiter, fatol, frtol, gatol, grtol, xtol, maxtime, verbose, stepback_strategy,
        subspace_solver, delta_init, mu, eta, theta_max, gamma1, gamma2, history_file
    )
end

"""
    _fides_options(fides_options::FidesOptions)::PythonCall.PythonCall.Py

Converts `fides_options` to a `pydict` as required by Fides.
"""
function _fides_options(fides_options::FidesOptions)::PythonCall.PythonCall.Py
    # Verbose level is provided directly to the solve-call
    options = PythonCall.pydict()
    options["maxiter"] = fides_options.maxiter
    options["fatol"] = fides_options.fatol
    options["frtol"] = fides_options.frtol
    options["gatol"] = fides_options.gatol
    options["grtol"] = fides_options.grtol
    options["maxtime"] = fides_options.maxtime
    options["delta_init"] = fides_options.delta_init
    options["mu"] = fides_options.mu
    options["eta"] = fides_options.eta
    options["theta_max"] = fides_options.theta_max
    options["gamma1"] = fides_options.gamma1
    options["gamma2"] = fides_options.gamma2
    # Use Fides default if not provided
    if !isnothing(fides_options.history_file)
        options["history_file"] = fides_options.history_file
    end
    # Sub-space solver and strategy are their own fides classes
    @unpack subspace_solver, stepback_strategy = fides_options
    options["subspace_solver"] = fides_py.constants.SubSpaceDim(subspace_solver)
    options["stepback_strategy"] = fides_py.constants.StepBackStrategy(stepback_strategy)
    return options
end

function _get_verbose_py(verbose::String)::Int64
    @assert verbose in LOGGING_LEVELS "Incorrect verbose level $verbose"
    if verbose == "warning"
        return 30
    elseif verbose == "info"
        return 20
    elseif verbose == "error"
        return 40
    end
    return 10
end
