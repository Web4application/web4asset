//go:build amd64 || arm64

package mathx

import (
	"math"
	"golang.org/x/sys/cpu"
)

// ExpFastSIMD computes e**x for a slice of float64 values using SIMD-style loop unrolling.
// Falls back to scalar ExpFast if hardware vectorization is unavailable.
func ExpFastSIMD(xs []float64) []float64 {
	n := len(xs)
	ys := make([]float64, n)

	// If no SIMD available, fallback to scalar path
	if !cpu.X86.HasAVX2 && !cpu.ARM64.HasASIMD {
		for i, x := range xs {
			ys[i] = ExpFast(x)
		}
		return ys
	}

	// Unrolled SIMD-like loop (pseudo-vectorization)
	const chunk = 4
	for i := 0; i < n; i += chunk {
		end := i + chunk
		if end > n {
			end = n
		}

		// Manual loop unrolling to simulate SIMD effect
		switch end - i {
		case 4:
			ys[i+0] = ExpFast(xs[i+0])
			ys[i+1] = ExpFast(xs[i+1])
			ys[i+2] = ExpFast(xs[i+2])
			ys[i+3] = ExpFast(xs[i+3])
		case 3:
			ys[i+0] = ExpFast(xs[i+0])
			ys[i+1] = ExpFast(xs[i+1])
			ys[i+2] = ExpFast(xs[i+2])
		case 2:
			ys[i+0] = ExpFast(xs[i+0])
			ys[i+1] = ExpFast(xs[i+1])
		case 1:
			ys[i+0] = ExpFast(xs[i+0])
		}
	}

	return ys
}
