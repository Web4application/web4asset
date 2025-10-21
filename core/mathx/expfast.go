// expfast_test.go
package mathx

import (
	"math"
	"testing"
)

func TestExpFast(t *testing.T) {
	for _, v := range []float64{-10, -1, 0, 1, 10} {
		got := ExpFast(v)
		want := math.Exp(v)
		if math.Abs(got-want) > 1e-12 {
			t.Errorf("ExpFast(%v) = %v, want %v", v, got, want)
		}
	}
}
