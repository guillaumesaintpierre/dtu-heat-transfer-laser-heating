"""Independent NumPy reproduction of the 5x5 explicit system described in the report.

This checks reported numerical outputs, not measured material response or MATLAB runtime.
Install NumPy, then run: python verification/check_report_numbers.py
"""
from __future__ import annotations
import math
import numpy as np


def compute(gas: bool, seconds: int) -> np.ndarray:
    k, rho, cp = 16.25, 7889, 518.3
    dx, dt = 0.01, 2.0
    fourier = k / (rho * cp) * dt / (dx * dx)
    x = np.linspace(-0.02, 0.02, 5)
    h = 100 + 900 * np.exp(-np.log(9 / 2) * (x / 0.01) ** 2)
    bi = h * dx / k
    absorbed_flux = 0.35 * 3000 / (math.pi * 0.02 ** 2)
    A, B = np.zeros((25, 25)), np.zeros(25)
    for j in range(5):
        for i in range(5):
            n = i + 5 * j
            if j == 4:
                B[n] = 20
            elif j == 0:
                c = float(bi[i]) if gas else 0.0
                A[n, n] = 1 - 4 * fourier - 2 * fourier * c
                if i == 0:
                    A[n, n + 1] = 2 * fourier
                elif i == 4:
                    A[n, n - 1] = 2 * fourier
                else:
                    A[n, n - 1] = fourier
                    A[n, n + 1] = fourier
                A[n, n + 5] = 2 * fourier
                B[n] = 2 * fourier * (absorbed_flux * dx / k + c * 20)
            else:
                A[n, n] = 1 - 4 * fourier
                A[n, n - 1] = 2 * fourier if i == 4 else (fourier if i > 0 else 0)
                A[n, n + 1] = 2 * fourier if i == 0 else (fourier if i < 4 else 0)
                A[n, n + 5] = fourier
                A[n, n - 5] = fourier
    assert np.all(np.diag(A)[:20] > 0), 'Explicit scheme not monotone under this dt'
    temp = np.full(25, 20.0)
    for _ in range(seconds // 2):
        temp = A @ temp + B
    return temp.reshape((5, 5))


def main() -> None:
    baseline10 = compute(False, 10)
    gas10 = compute(True, 10)
    baseline50 = compute(False, 50)
    expected = {'baseline_10s_surface_c': 325.9,
                'gas_10s_center_surface_c': 278.7,
                'baseline_50s_surface_c': 815.2}
    actual = {'baseline_10s_surface_c': baseline10[0, 2],
              'gas_10s_center_surface_c': gas10[0, 2],
              'baseline_50s_surface_c': baseline50[0, 2]}
    for name, value in actual.items():
        assert abs(value - expected[name]) < 0.06, (name, value, expected[name])
        print(f'{name}: {value:.3f} C (report: {expected[name]:.1f} C)')
    assert np.max(np.ptp(baseline10, axis=1)) < 1e-10
    assert gas10[0, 2] < gas10[0, 0]
    print('PASS - Numerical outputs reproduce selected reported values.')


if __name__ == '__main__':
    main()
