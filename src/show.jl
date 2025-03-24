import Base.show

function Base.show(io::IO, prob::FidesProblem)
    nps = length(prob.x0)
    header = styled"{bold:FidesProblem} with $(nps) parameters to estimate"
    print(io, styled"$(header)")
end
function Base.show(io::IO, res::FidesSolution)
    header = styled"{bold:FidesSolution}"
    optheader = styled"\n---------------- {bold:Summary} ---------------\n"
    opt1 = @sprintf("min(f)                = %.2e\n", res.fmin)
    opt2 = @sprintf("Parameters estimated  = %d\n", length(res.xmin))
    opt3 = @sprintf("Optimiser iterations  = %d\n", res.niterations)
    opt4 = @sprintf("Runtime               = %.1es\n", res.runtime)
    print(io, styled"$(header)$(optheader)$(opt1)$(opt2)$(opt3)$(opt4)")
end
