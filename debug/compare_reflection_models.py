#!/usr/bin/env python3
"""Compare decoupled slope mapping vs exact 3D reflection mapping on synthetic surfaces.
No third-party dependencies.
"""
import math


def make_grid(n, L):
    vals = [i * L / (n - 1) for i in range(n)]
    X = [[vals[j] for j in range(n)] for _ in range(n)]
    Y = [[vals[i] for _ in range(n)] for i in range(n)]
    return X, Y, vals


def eta_case(kind, x, y):
    if kind == "single-mode":
        return 0.04 * math.sin(3 * x) * math.cos(2 * y)
    if kind == "steeper":
        return 0.12 * math.sin(5 * x + 0.7) * math.cos(4 * y - 0.2)
    raise ValueError(kind)


def build_eta(kind, X, Y, n):
    return [[eta_case(kind, X[i][j], Y[i][j]) for j in range(n)] for i in range(n)]


def gradients(ETA, h):
    n = len(ETA)
    ex = [[0.0] * n for _ in range(n)]
    ey = [[0.0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            jm1 = max(j - 1, 0)
            jp1 = min(j + 1, n - 1)
            im1 = max(i - 1, 0)
            ip1 = min(i + 1, n - 1)
            dx = (jp1 - jm1) * h if jp1 != jm1 else h
            dy = (ip1 - im1) * h if ip1 != im1 else h
            ex[i][j] = (ETA[i][jp1] - ETA[i][jm1]) / dx
            ey[i][j] = (ETA[ip1][j] - ETA[im1][j]) / dy
    return ex, ey


def compare(kind, n=128, L=2 * math.pi, D_rel=0.25):
    X, Y, vals = make_grid(n, L)
    ETA = build_eta(kind, X, Y, n)
    h = vals[1] - vals[0]
    ex, ey = gradients(ETA, h)
    D = D_rel * (vals[-1] - vals[0])

    sum_abs_dx = sum_abs_dy = sum_dr = 0.0
    max_abs_dx = max_abs_dy = max_dr = 0.0
    count = n * n

    for i in range(n):
        for j in range(n):
            eta = ETA[i][j]
            p = ex[i][j]
            q = ey[i][j]

            x_dec = X[i][j] + 2 * (D - eta) * p / (1 - p * p)
            y_dec = Y[i][j] + 2 * (D - eta) * q / (1 - q * q)

            den = 1 - p * p - q * q
            x_ex = X[i][j] - 2 * (D - eta) * p / den
            y_ex = Y[i][j] - 2 * (D - eta) * q / den

            dx = x_dec - x_ex
            dy = y_dec - y_ex
            dr = math.hypot(dx, dy)

            adx = abs(dx)
            ady = abs(dy)
            sum_abs_dx += adx
            sum_abs_dy += ady
            sum_dr += dr
            max_abs_dx = max(max_abs_dx, adx)
            max_abs_dy = max(max_abs_dy, ady)
            max_dr = max(max_dr, dr)

    print(f"{kind}:")
    print(f"  mean |Δx|={sum_abs_dx/count:.6e}, mean |Δy|={sum_abs_dy/count:.6e}")
    print(f"  max  |Δx|={max_abs_dx:.6e}, max  |Δy|={max_abs_dy:.6e}")
    print(f"  mean |Δr|={sum_dr/count:.6e}, max |Δr|={max_dr:.6e}")


if __name__ == "__main__":
    compare("single-mode")
    compare("steeper")
