#include "textflag.h"

import "golang.org/x/sys/cpu"

func ExpFastSIMD(xs []float64) []float64 {
    ys := make([]float64, len(xs))
    if cpu.X86.HasAVX2 {
        expFastAVX2(xs, ys)
        return ys
    }
    for i, x := range xs {
        ys[i] = ExpFast(x)
    }
    return ys
}

// func expFastAVX2(xs, ys []float64)
TEXT ·expFastAVX2(SB), NOSPLIT, $0-48
    MOVQ xs_base+0(FP), RDI      // &xs[0]
    MOVQ ys_base+24(FP), RSI     // &ys[0]
    MOVQ xs_len+8(FP), RAX       // n = len(xs)
    XORQ RBX, RBX                // i = 0

loop:
    CMPQ RBX, RAX
    JAE done

    // load 4 doubles into YMM0
    VMOVUPD (RDI)(RBX*8), Y0

    // polynomial approx: e^x ≈ 1 + x + x^2/2 + x^3/6 + x^4/24
    VMULPD Y0, Y0, Y1            // x^2
    VADDPD Y1, Y0, Y2            // x + x^2
    VFMADD231PD Y1, Y0, Y2       // += x^3
    VMULPD Y1, Y1, Y3            // x^4
    VFMADD231PD Y3, Y0, Y2       // += x^4 term
    VADDPD Y2, Y0, Y4
    VADDPD Y4, Y0, Y5            // crude poly expansion

    // store back
    VMOVUPD Y5, (RSI)(RBX*8)

    ADDQ $4, RBX
    JMP loop

done:
    VZEROUPPER
    RET
