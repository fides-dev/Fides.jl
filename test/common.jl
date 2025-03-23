using ComponentArrays, ForwardDiff

rosenbrock(u) = (1.0 - u[1])^2 + 100.0 * (u[2] - u[1]^2)^2

rosenbrock_grad! = (g, x) -> begin
    ForwardDiff.gradient!(g, rosenbrock, x)
end

rosenbrock_grad = (x) -> begin
    ForwardDiff.gradient(rosenbrock, x)
end

rosenbrock_hess = (x) -> begin
    ForwardDiff.hessian(rosenbrock, x)
end

rosenbrock_hess! = (H, x) -> begin
    ForwardDiff.hessian!(H, rosenbrock, x)
end

# ComponentArrays input
rosenbrock_comp(u) = (1.0 - u.p1)^2 + 100.0 * (u.p2 - u.p1^2)^2

rosenbrock_comp_grad! = (g, x) -> begin
    ForwardDiff.gradient!(g, rosenbrock_comp, x)
end

rosenbrock_comp_hess! = (H, x) -> begin
    ForwardDiff.hessian!(H, rosenbrock_comp, x)
end
