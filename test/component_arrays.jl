using ComponentArrays, Fides, Test

include(joinpath(@__DIR__, "common.jl"))

x0 = ComponentArray(p1 = 2.0, p2 = 2.0)
lb = ComponentArray(p1 = -10.0, p2 = -10.0)
ub = ComponentArray(p1 = 10.0, p2 = 10.0)

@testset "ComponentArrays" begin
    prob1 = FidesProblem(rosenbrock_comp, rosenbrock_comp_grad!, x0; lb = lb, ub = ub)
    sol1 = solve(prob1, Fides.BFGS())
    @test all(.≈(sol1.xmin, [1.0, 1.0]; atol = 1.0e-6))

    prob2 = FidesProblem(
        rosenbrock_comp, rosenbrock_comp_grad!, x0; hess! = rosenbrock_comp_hess!, lb = lb,
        ub = ub
    )
    sol2 = solve(prob2, Fides.CustomHessian())
    @test all(.≈(sol1.xmin, [1.0, 1.0]; atol = 1.0e-6))
end
