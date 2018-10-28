package main

type ColorReducer struct {
	downgradeFunc func(a, cNum int32) int32
}

func reduceColor(a, bits int32) int32 {
	var maxv = int32((1 << uint32(bits)) - 1)
	// ((a / 255.f) * maxv) / maxv * 255.f
	return a * maxv / 255 * 255 / maxv
}

var lookup4444 [256]int32

func initLookup() {
	for i := range lookup4444 {
		lookup4444[i] = reduceColor(int32(i), 4)
	}
}

func reduce4444(a, cNum int32) int32 {
	return lookup4444[a]
}

func (reducer *ColorReducer) Init() {
	reducer.downgradeFunc = reduce4444
	initLookup()
}

func (reducer *ColorReducer) Closest(src, out *Rgba) {
	for i := int32(0); i < 4; i++ {
		out[i] = reducer.downgradeFunc(src[i], i)
	}
}
