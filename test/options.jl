using Fides, PythonCall, Test

include(joinpath(@__DIR__, "common.jl"))

fides_prob = FidesProblem(
    rosenbrock, rosenbrock_grad!, [2.0, 2.0]; lb = [-10.0, -10.0], ub = [10.0, 10.0]
)

@testset "Fides options" begin
    # Test defaults are correct
    opt = FidesOptions()
    @test opt.maxiter == 1000
    @test opt.fatol == 1.0e-8
    @test opt.frtol == 1.0e-8
    @test opt.gatol == 1.0e-6
    @test opt.grtol == 0.0
    @test opt.maxtime == Inf
    @test opt.verbose_level == "warning"
    @test opt.stepback_strategy == "reflect"
    @test opt.subspace_solver == "2D"
    @test opt.delta_init == 1.0
    @test opt.mu == 0.25
    @test opt.eta == 0.75
    @test opt.theta_max == 0.95
    @test opt.gamma1 == 0.25
    @test opt.gamma2 == 2.0

    # Test that all options can be set to none-default values
    opt = FidesOptions(
        maxiter = 100, fatol = 1.0e-6, frtol = 1.0e-5, gatol = 1.0e-3, maxtime = 10.0,
        grtol = 1.0e-2, verbose = "warning", stepback_strategy = "refine",
        subspace_solver = "full", delta_init = 2.0, mu = 0.3, eta = 0.8, theta_max = 0.99,
        gamma1 = 0.2, gamma2 = 1.9
    )
    @test opt.maxiter == 100
    @test opt.fatol == 1.0e-6
    @test opt.frtol == 1.0e-5
    @test opt.gatol == 1.0e-3
    @test opt.grtol == 1.0e-2
    @test opt.maxtime == 10.0
    @test opt.verbose_level == "warning"
    @test opt.stepback_strategy == "refine"
    @test opt.subspace_solver == "full"
    @test opt.delta_init == 2.0
    @test opt.mu == 0.3
    @test opt.eta == 0.8
    @test opt.theta_max == 0.99
    @test opt.gamma1 == 0.2
    @test opt.gamma2 == 1.9
    # Test options are properly converted to Python
    opt_py = Fides._fides_options(opt)
    @test pyconvert(Int64, opt_py["maxiter"]) == 100
    @test pyconvert(Float64, opt_py["fatol"]) == 1.0e-6
    @test pyconvert(Float64, opt_py["frtol"]) == 1.0e-5
    @test pyconvert(Float64, opt_py["gatol"]) == 1.0e-3
    @test pyconvert(Float64, opt_py["gatol"]) == 1.0e-3
    @test pyconvert(Float64, opt_py["maxtime"]) == 10.0
    @test pyconvert(Float64, opt_py["grtol"]) == 1.0e-2
    @test pyconvert(String, opt_py["stepback_strategy"]._name_) == "REFINE"
    @test pyconvert(String, opt_py["subspace_solver"]._name_) == "FULL"
    @test pyconvert(Float64, opt_py["delta_init"]) == 2.0
    @test pyconvert(Float64, opt_py["mu"]) == 0.3
    @test pyconvert(Float64, opt_py["eta"]) == 0.8
    @test pyconvert(Float64, opt_py["theta_max"]) == 0.99
    @test pyconvert(Float64, opt_py["gamma1"]) == 0.2
    @test pyconvert(Float64, opt_py["gamma2"]) == 1.9

    # Test options with limited choices throw if incorrect input
    @test_throws ArgumentError FidesOptions(verbose = "tada")
    @test_throws ArgumentError FidesOptions(subspace_solver = "tada")
    @test_throws ArgumentError FidesOptions(stepback_strategy = "tada")

    # Test options are propagated to solve
    sol = solve(fides_prob, Fides.BFGS(); options = FidesOptions(maxiter = 2))
    @test sol.niterations == 2
    sol = solve(
        fides_prob, Fides.BFGS();
        options = FidesOptions(fatol = 0.0, frtol = 0.0, gatol = 0.0)
    )
    @test sol.retcode == :GTOL
    sol = solve(
        fides_prob, Fides.BFGS(); options = FidesOptions(stepback_strategy = "refine")
    )
    @test sol.fmin ≈ 0.0 atol = 1.0e-8
    sol = solve(fides_prob, Fides.BFGS(); options = FidesOptions(subspace_solver = "full"))
    @test sol.fmin ≈ 0.0 atol = 1.0e-8
end
