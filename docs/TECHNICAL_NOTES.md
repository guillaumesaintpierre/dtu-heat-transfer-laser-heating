# Technical notes and reproducibility

**Model:** transient heat equation, 316L steel, constant thermal properties, no radiation/phase change, surface laser heat input, insulated sides, fixed base. Five nodal control volumes in each direction.

## Computed outputs and analytical comparisons

The report's Table 4 contains:

| y (cm) | t=10 s: analytic (°C) | t=10 s: FVM (°C) | t=20 s: analytic (°C) | t=20 s: FVM (°C) |
|---:|---:|---:|---:|---:|
| 0 | 385.7 | 325.9 | 537.2 | 497.9 |
| 1 | 80.3 | 67.2 | 177.8 | 157.4 |
| 2 | 24.0 | 24.0 | 51.1 | 47.8 |
| 3 | 20.1 | 20.2 | 23.8 | 24.0 |
| 4 | 20.0 | 20.0 | 20.3 | 20.0 |

The 50 s surface results reported in Section 11 are FVM **815.2 °C**, analytical **837.9 °C**. The computed 10 s gas-cooled centre-surface temperature reported in Section 9 is **278.7 °C**, against **325.9 °C** without gas.

## Numerical verification carried out for the GitHub preparation

The script `verification/check_report_numbers.py` independently assembles the same explicit 5x5 finite-volume coefficient matrix in Python and checks the three headline results to 0.06 °C tolerance. It also checks exact x-symmetry for the baseline and the expected centre cooling direction. It runs using NumPy without external data or experimental measurements.

**Verified:** discrete model reproduces selected submitted outputs.

**Not verified:** the transcription executing in MATLAB or Octave; mesh convergence; comparison with experimental measurements; temperature-dependent material properties; effects of melting and radiation. Those remain future extensions and should not be stated as completed work.

## Why the temperature result should not be over-interpreted

The time step satisfies the report's explicit coefficient-positivity condition. However, the coarse 1 cm spacing and 316L constant-property approximation lead to substantial differences from the semi-infinite analytical reference at 10 s, particularly at the heated surface. At later times the fixed-temperature bottom and infinite-domain assumptions diverge. This repository demonstrates finite-volume modelling, numerical validation logic and heat-transfer interpretation, not a high-fidelity laser-manufacturing prediction.
