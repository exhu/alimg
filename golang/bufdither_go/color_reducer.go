package main

type ColorReducer struct {
	downgradeFunc func(a, cNum int) int
}

func reduceColor(a, bits int) int {
	var maxv = ((1 << uint(bits)) - 1)
	// ((a / 255.f) * maxv) / maxv * 255.f
	return a * maxv / 255 * 255 / maxv
}

var lookup4444 [256]int

func initLookup() {
	for i := range lookup4444 {
		lookup4444[i] = reduceColor(i, 4)
	}
}

func reduce4444(a, cNum int) int {
	return lookup4444[a]
}

func (reducer *ColorReducer) Init() {
	reducer.downgradeFunc = reduce4444
	initLookup()
}

func (reducer *ColorReducer) Closest(src, out *Rgba) {
	for i, v := range src {
		out[i] = reducer.downgradeFunc(v, i)
	}
}
