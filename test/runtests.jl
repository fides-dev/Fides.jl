using SafeTestsets

@safetestset "Aqua Quality Check" begin
    include("aqua.jl")
end

@safetestset "Fides Options" begin
    include("options.jl")
end

@safetestset "Fides Problem" begin
    include("problem.jl")
end

@safetestset "ComponentArrays" begin
    include("component_arrays.jl")
end

@safetestset "Hessian approximations" begin
    include("hess_approximations.jl")
end

@safetestset "Show" begin
    include("show.jl")
end
