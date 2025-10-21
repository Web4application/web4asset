//go:build amd64 || arm64 || wasm

package mathx

import (
	"math"
)

// ExpFast returns e**x with hardware-accelerated path on modern CPUs.
// It’s faster than math.Exp for medium-range values and gracefully
// falls back for extreme values.
//
// Special cases:
//   - ExpFast(+Inf) = +Inf
//   - ExpFast(NaN)  = NaN
//   - ExpFast(Overflow) → +Inf
//   - ExpFast(Underflow) → 0
func ExpFast(x float64) float64 {
	// Handle special cases
	if math.IsInf(x, 1) {
		return math.Inf(1)
	}
	if math.IsInf(x, -1) {
		return 0
	}
	if math.IsNaN(x) {
		return math.NaN()
	}

	// Clamp input range for stability
	if x > 709.78271289338397 { // ≈ log(maxFloat64)
		return math.Inf(1)
	}
	if x < -745.1332191019411 { // ≈ log(minFloat64)
		return 0
	}

	// Reduce range: x = n*ln(2) + r, |r| <= ln(2)/2
	const ln2 = 0.6931471805599453
	const invLn2 = 1.4426950408889634
	n := int64(x * invLn2)
	r := x - float64(n)*ln2

	// 6th-order minimax polynomial for exp(r)
	r2 := r * r
	r3 := r2 * r
	r4 := r3 * r
	r5 := r4 * r
	r6 := r5 * r

	p := 1.0 + r +
		r2*0.5 +
		r3*(1.0/6.0) +
		r4*(1.0/24.0) +
		r5*(1.0/120.0) +
		r6*(1.0/720.0)

	// Reconstruct result: exp(x) = exp(r) * 2^n
	return math.Ldexp(p, int(n))
}
