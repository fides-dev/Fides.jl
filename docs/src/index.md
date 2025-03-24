# Fides.jl

Fides.jl is a Julia wrapper of the Python package [Fides.py](https://github.com/fides-dev/fides), which implements an Interior Trust Region Reflective for boundary costrained optimization problems based on [ADD]. Fides targets problems on the form:

```math
\min_{x \in \mathbb{R}^n} f(x) \quad \mathrm{subject \ to} \quad lb \leq x \leq ub
```

Where `f` is a continues at least twice-differentaible function, and `lb` and `ub` are the lower and upper bounds respectively.

## Highlights

- Boundary-constrained interior trust-region optimization.
- Recursive reflective and truncated constraint management.
- Full and 2D subproblem solution solvers.
- Supports used provided HEssian, and BFGS, DFP, and SR1 Hessian approximations.
- Good performance for parameter estimating Ordinary Differential Equation models.

!!! note "Star us on GitHub!"
    If you find the package useful in your work please consider giving us a star on [GitHub](https://github.com/sebapersson/Fides.jl). This will help us secure funding in the future to continue maintaining the package.

## Installation

To install Fides.jl in the Julia REPL enter

```julia
julia> ] add Fides
```

or alternatively

```julia
julia> using Pkg; Pkg.add("Fides")
```

Fides is compatible with Julia version 1.10 and above. For best performance we strongly recommend using the latest Julia version.

## Getting help

If you have any problems using Fides, here are some helpful tips:

- Consult the Fides Python [documentation](https://fides-optimizer.readthedocs.io/en/latest/about.html).
- Post your questions in the `#sciml-sysbio` or `#math-optimization` channel on the [Julia Slack](https://julialang.org/slack/).
- If you have encountered unexpected behavior or a bug, please open an issue on [GitHub](https://github.com/sebapersson/Fides.jl).

## Citation

If you found Fides useful in your work, please cite the following paper:

```bibtex
@article{2022fides,
  title={Fides: Reliable trust-region optimization for parameter estimation of ordinary differential equation models},
  author={Fr{\"o}hlich, Fabian and Sorger, Peter K},
  journal={PLoS computational biology},
  volume={18},
  number={7},
  pages={e1010322},
  year={2022},
  publisher={Public Library of Science San Francisco, CA USA}
}
```
