using Fides, ForwardDiff, Test

include(joinpath(@__DIR__, "common.jl"))

function test_hess_approximation(prob, hess_approximation; tol_fmin = 1e-8, tol_xmin = 1e-4)
    sol = solve(prob, hess_approximation; options = FidesOptions(; maxiter = 100000))
    @test sol.fmin≈0.0 atol=tol_fmin
    @test all(.≈(sol.xmin, [1.0, 1.0], atol = tol_xmin))
    return nothing
end

fides_prob = FidesProblem(rosenbrock, rosenbrock_grad!, [2.0, 2.0]; lb = [-10.0, -10.0],
                          ub = [10.0, 10.0])

@testset "Hessian approximations" begin
    # Good approximation methods, should converge without problems
    test_hess_approximation(fides_prob, Fides.BFGS())
    test_hess_approximation(fides_prob, Fides.SR1())
    test_hess_approximation(fides_prob, Fides.Broyden(0.5))
    # Worse approximation methods, should converge somewhat
    test_hess_approximation(fides_prob, Fides.DFP(); tol_fmin = 1e-3, tol_xmin = 1e-1)
    test_hess_approximation(fides_prob, Fides.BB(); tol_fmin = 1e-3, tol_xmin = 1e-1)
    test_hess_approximation(fides_prob, Fides.BG(); tol_fmin = 1e-3, tol_xmin = 1e-1)
    # Try to provide a custom initialization Hessian
    init_hess = [0.1 0.0; 0.0 0.1]
    test_hess_approximation(fides_prob, Fides.BFGS(init_hess = init_hess))
    test_hess_approximation(fides_prob, Fides.SR1(init_hess = init_hess))
    test_hess_approximation(fides_prob, Fides.Broyden(0.5; init_hess = init_hess))
    # Other Hessian options
    test_hess_approximation(fides_prob, Fides.BFGS(enforce_curv_cond = false))
    test_hess_approximation(fides_prob, Fides.Broyden(0.5; enforce_curv_cond = false))
end
