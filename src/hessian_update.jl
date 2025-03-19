"""
    BB(; init_hess = nothing}
The Broydens “bad” method as introduced in [1]. This is a rank 1 update strategy that does
not preserve symmetry or positive definiteness.

## Keyword arguments
- `init_hess = nothing`: Initial Hessian for the update scheme. If provided as a `Matrix`,
    the given matrix is used; if set to `nothing` (default), the identity matrix is used.

## References
1. https://doi.org/10.1090%2FS0025-5718-1965-0198670-6
"""
struct BB{T <: Union{Nothing, AbstractMatrix}}
    init_hess::T
    init_with_hess::Bool
end
function BB(; init_hess::Union{Nothing, AbstractMatrix} = nothing)
    init_with_hess = _get_init_with_hess(init_hess)
    return BB(init_hess, init_with_hess)
end

"""
    SR1(; init_hess = nothing)

The Symmetric Rank 1 update strategy as described in [1]. This is a rank 1 update strategy
that preserves symmetry but does not preserve positive-semidefiniteness.

## Keyword arguments
- `init_hess = nothing`: Initial Hessian for the update scheme. If provided as a `Matrix`,
    the given matrix is used; if set to `nothing` (default), the identity matrix is used.

## References
1. [Nocedal & Wright](http://dx.doi.org/10.1007/b98874) Chapter 6.2
"""
struct SR1{T <: Union{Nothing, AbstractMatrix}}
    init_hess::T
    init_with_hess::Bool
end
function SR1(; init_hess::Union{Nothing, AbstractMatrix} = nothing)
    init_with_hess = _get_init_with_hess(init_hess)
    return SR1(init_hess, init_with_hess)
end

"""
    BG(; init_hess = nothing}

Broydens “good” method as introduced in [1]. This is a rank 1 update strategy that does not
preserve symmetry or positive definiteness.

## Keyword arguments
- `init_hess = nothing`: Initial Hessian for the update scheme. If provided as a `Matrix`,
    the given matrix is used; if set to `nothing` (default), the identity matrix is used.

## References
1. [Broyden 1965](https://doi.org/10.1090%2FS0025-5718-1965-0198670-6)
"""
struct BG{T <: Union{Nothing, AbstractMatrix}}
    init_hess::T
    init_with_hess::Bool
end
function BG(; init_hess::Union{Nothing, AbstractMatrix} = nothing)
    init_with_hess = _get_init_with_hess(init_hess)
    return BG(init_hess, init_with_hess)
end

"""
    BFGS(; init_hess = nothing, enforce_curv_cond::Bool = true)

The Broyden-Fletcher-Goldfarb-Shanno (BFGS) update strategy is a rank-2 update method that
preserves both symmetry and positive-semidefiniteness.

## Keyword arguments
- `init_hess = nothing`: Initial Hessian for the update scheme. If provided as a `Matrix`,
    the given matrix is used; if set to `nothing` (default), the identity matrix is used.
- `enforce_curv_cond = true`: Whether the update should attempt to preserve positive
    definiteness. If `true`, updates from steps that violate the curvature condition are
    discarded.
"""
struct BFGS{T <: Union{Nothing, AbstractMatrix}}
    init_hess::T
    enforce_curv_cond::Bool
    init_with_hess::Bool
end
function BFGS(; init_hess::Union{Nothing, AbstractMatrix} = nothing, enforce_curv_cond::Bool = true)
    init_with_hess = _get_init_with_hess(init_hess)
    return BFGS(init_hess, enforce_curv_cond, init_with_hess)
end

"""
    DFP(; init_hess = nothing, enforce_curv_cond::Bool = true)

The Davidon-Fletcher-Powell update strategy. This is a rank 2 update strategy that preserves
symmetry and positive-semidefiniteness.

## Keyword arguments
- `init_hess = nothing`: Initial Hessian for the update scheme. If provided as a `Matrix`,
    the given matrix is used; if set to `nothing` (default), the identity matrix is used.
- `enforce_curv_cond = true`: Whether the update should attempt to preserve positive
    definiteness. If `true`, updates from steps that violate the curvature condition are
    discarded.
"""
struct DFP{T <: Union{Nothing, AbstractMatrix}}
    init_hess::T
    enforce_curv_cond::Bool
    init_with_hess::Bool
end
function DFP(; init_hess::Union{Nothing, AbstractMatrix} = nothing, enforce_curv_cond::Bool = true)
    init_with_hess = _get_init_with_hess(init_hess)
    return DFP(init_hess, enforce_curv_cond, init_with_hess)
end

"""
    Broyden(phi; init_hess = nothing, enforce_curv_cond::Bool = true)

The update scheme, as described in [1], which is a generalization of the BFGS/DFP methods
where `phi` controls the convex combination between the two. This rank-2 update strategy
preserves both symmetry and positive-semidefiniteness when `0 < phi < 1`.

## Arguments
- `phi::AbstractFloat`: The convex combination parameter interpolating between BFGS
    (`phi=0`) and DFP (`phi=1`).

## Keyword arguments
- `init_hess = nothing`: Initial Hessian for the update scheme. If provided as a `Matrix`,
    the given matrix is used; if set to `nothing` (default), the identity matrix is used.
- `enforce_curv_cond = true`: Whether the update should attempt to preserve positive
    definiteness. If `true`, updates from steps that violate the curvature condition are
    discarded.

## References
1. [Nocedal & Wright]( http://dx.doi.org/10.1007/b98874) Chapter 6.3
"""
struct Broyden{T <: Union{Nothing, AbstractMatrix}}
    phi::Float64
    init_hess::T
    enforce_curv_cond::Bool
    init_with_hess::Bool
end
function Broyden(phi::AbstractFloat; init_hess::Union{Nothing, AbstractMatrix} = nothing, enforce_curv_cond::Bool = true)
    init_with_hess = _get_init_with_hess(init_hess)
    return Broyden(phi, init_hess, enforce_curv_cond, init_with_hess)
end
