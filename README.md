# Fides.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://sebapersson.github.io/Fides.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://sebapersson.github.io/Fides.jl/dev/)
[![Build Status](https://github.com/sebapersson/Fides.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/sebapersson/Fides.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![codecov](https://codecov.io/gh/sebapersson/Fides.jl/graph/badge.svg?token=J7PXRF30JG)](https://codecov.io/gh/sebapersson/Fides.jl)
[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)

Fides.jl is a Julia wrapper of the Python package [Fides.py](https://github.com/fides-dev/fides), which implements an Interior Trust Region Reflective for boundary costrained optimization problems based on [ADD]. Fides targets problems on the form:

```math
\min_{x \in \mathbb{R}^n} f(x) \quad \mathrm{subject \ to} \ lb \leq x \leq ub
```

Where `f` is a continues at least twice-differentaible function, and `lb` and `ub` are the lower and upper bounds respectively.

## Highlights

- Boundary-constrained interior trust-region optimization.
- Recursive reflective and truncated constraint management.
- Full and 2D subproblem solution solvers.
- Supports used provided HEssian, and BFGS, DFP, and SR1 Hessian approximations.
- Good performance for parameter estimating Ordinary Differential Equation models.

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
