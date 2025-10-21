package compute

import (
    "math"
)

// Exp calculates e^x (exponential growth) using a fast polynomial method.
// It’s the same core math used in Web4Asset’s AI models and finance logic.
func Exp(x float64) float64 {
    // Handle extreme or invalid inputs
    switch {
    case math.IsNaN(x):
        return math.NaN()
    case x == math.Inf(1):
        return math.Inf(1)
    case x == math.Inf(-1):
        return 0
    }

    // Constants for range reduction
    const (
        Ln2Hi  = 6.93147180369123816490e-01  // High part of ln(2)
        Ln2Lo  = 1.90821492927058770002e-10  // Low part of ln(2)
        InvLn2 = 1.44269504088896338700e+00 // 1/ln(2)
    )

    // Reduce range: express x as k*ln(2) + r, with small |r|
    k := int64(x * InvLn2 + math.Copysign(0.5, x))
    r := x - float64(k)*Ln2Hi - float64(k)*Ln2Lo

    // Polynomial approximation for e^r
    const (
        P1 = 1.66666666666666019037e-01
        P2 = -2.77777777770155933842e-03
        P3 = 6.61375632143793436117e-05
        P4 = -1.65339022054652515390e-06
        P5 = 4.13813679705723846039e-08
    )

    r2 := r * r
    y := (((((P5*r + P4)*r + P3)*r + P2)*r + P1)*r2) + r + 1

    // Scale result back
    return math.Ldexp(y, int(k))
}
