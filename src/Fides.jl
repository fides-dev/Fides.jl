module Fides

using ComponentArrays: ComponentVector
import PythonCall
using SimpleUnPack: @unpack

# To avoid pre-compilation problems
const fides_py = PythonCall.pynew()
const np_py = PythonCall.pynew()

function __init__()
    PythonCall.pycopy!(fides_py, PythonCall.pyimport("fides"))
    PythonCall.pycopy!(np_py, PythonCall.pyimport("numpy"))
end

const STEPBACK_STRATEGIES = ["mixed", "refine", "reflect", "reflect_single", "truncate"]
const SUBSPACE_SOLVERS = ["full", "scg", "2D"]
const LOGGING_LEVELS = ["warning", "info", "error", "debug"]
const InputVector = Union{Vector{<:Real}, ComponentVector{<:Real}}

include(joinpath(@__DIR__, "hessian_update.jl"))
const HessianUpdate = Union{BB, SR1, BG, BFGS, DFP, Broyden}

include(joinpath(@__DIR__, "problem.jl"))
include(joinpath(@__DIR__, "options.jl"))
include(joinpath(@__DIR__, "solve.jl"))

public BB, SR1, BG, BFGS, DFP, Broyden
export solve, FidesProblem, FidesOptions

end
