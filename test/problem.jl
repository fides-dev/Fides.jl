using Fides, ForwardDiff, Test

include(joinpath(@__DIR__, "common.jl"))

function fides_obj1(x)
    f = rosenbrock(x)
    g = rosenbrock_grad(x)
    return (f, g)
end

function fides_obj2(x)
    f = rosenbrock(x)
    g = rosenbrock_grad(x)
    H = rosenbrock_hess(x)
    return (f, g, H)
end

# Testing catching incorrect number of returned arguments
function fides_obj3(x)
    return rosenbrock(x)
end

function fides_obj4(x)
    f = rosenbrock(x)
    return [f, f, f, f]
end

x0, lb, ub = [2.0, 2.0], [-10.0, -10.0], [10.0, 10.0]
@testset "FidesProblem" begin
    prob1 = FidesProblem(rosenbrock, rosenbrock_grad!, x0; lb = lb, ub = ub)
    sol1 = solve(prob1, Fides.BFGS())
    @test all(.≈(sol1.xmin, [1.0, 1.0]; atol = 1e-6))

    prob2 = FidesProblem(rosenbrock, rosenbrock_grad!, x0; hess! = rosenbrock_hess!,
        lb = lb, ub = ub)
    sol2 = solve(prob2, Fides.CustomHessian())
    @test all(.≈(sol2.xmin, [1.0, 1.0]; atol = 1e-6))

    prob3 = FidesProblem(fides_obj1, x0; lb = lb, ub = ub)
    sol3 = solve(prob3, Fides.BFGS())
    @test all(.≈(sol3.xmin, [1.0, 1.0]; atol = 1e-6))

    prob4 = FidesProblem(fides_obj2, x0; lb = lb, ub = ub)
    sol4 = solve(prob4, Fides.CustomHessian())
    @test all(.≈(sol4.xmin, [1.0, 1.0]; atol = 1e-6))

    # No bounds
    prob5 = FidesProblem(fides_obj2, x0)
    sol5 = solve(prob5, Fides.CustomHessian())
    @test all(.≈(sol5.xmin, [1.0, 1.0]; atol = 1e-6))

    # Check correct Hessian input handling
    @test_throws ArgumentError begin
        solve(prob3, Fides.CustomHessian())
    end
    @test_throws ArgumentError begin
        solve(prob4, Fides.BFGS())
    end
    @test_throws ArgumentError begin
        FidesProblem(fides_obj3, x0)
    end
    @test_throws ArgumentError begin
        FidesProblem(fides_obj4, x0)
    end
end
