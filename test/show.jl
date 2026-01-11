using Fides, Printf, Test

include(joinpath(@__DIR__, "common.jl"))

x0, lb, ub = [2.0, 2.0], [-10.0, -10.0], [10.0, 10.0]
prob = FidesProblem(rosenbrock, rosenbrock_grad!, x0; lb = lb, ub = ub)
sol = solve(prob, Fides.BFGS())

@testset "show" begin
    @test @sprintf("%s", prob) == "FidesProblem with 2 parameters to estimate"
    @test @sprintf("%s", sol)[1:140] == "FidesSolution\n---------------- Summary ---------------\nmin(f)                = 3.30e-14\nParameters estimated  = 2\nOptimiser iterations  = 46"
end
