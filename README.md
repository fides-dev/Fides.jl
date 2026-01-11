# Fides.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://fides-dev.github.io/Fides.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://fides-dev.github.io/Fides.jl/dev/)
[![Build Status](https://github.com/fides-dev/Fides.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/fides-dev/Fides.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![codecov](https://codecov.io/gh/fides-dev/Fides.jl/graph/badge.svg?token=J7PXRF30JG)](https://codecov.io/gh/fides-dev/Fides.jl)
[![code style: runic](https://img.shields.io/badge/code_style-%E1%9A%B1%E1%9A%A2%E1%9A%BE%E1%9B%81%E1%9A%B2-black)](https://github.com/fredrikekre/Runic.jl)

Fides.jl is a Julia wrapper of the Python package [Fides.py](https://github.com/fides-dev/fides), which implements an Interior Trust Region Reflective algorithm for bounds constrained optimization problems based on [1, 2]. Fides targets problems on the form:

```math
\min_{x \in \mathbb{R}^n} f(x) \quad \mathrm{subject \ to} \quad \text{lb} \leq x \leq \text{ub}
```

Where `f` is a continues at least twice-differentiable function, and `lb` and `ub` are the lower and upper bounds respectively.

## Main features

- Boundary-constrained interior trust-region optimization.
- Recursive reflective and truncated constraint management.
- Full and 2D subproblem solution solvers.
- Supports used provided Hessian, as well as BFGS, DFP, and SR1 Hessian approximations.
- Good performance for parameter estimating Ordinary Differential Equation models [3].

Additional information and tutorials can be found in the documentation.

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

## References

1. Coleman, T. F., & Li, Y. (1994). On the convergence of interior-reflective Newton methods for nonlinear minimization subject to bounds. Mathematical programming, 67(1), 189-224.
2. Coleman, T. F., & Li, Y. (1996). An interior trust region approach for nonlinear minimization subject to bounds. SIAM Journal on optimization, 6(2), 418-445.
3. Fröhlich, F., & Sorger, P. K. (2022). Fides: Reliable trust-region optimization for parameter estimation of ordinary differential equation models. PLoS computational biology, 18(7), e1010322.
