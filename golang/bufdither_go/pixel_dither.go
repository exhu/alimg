package main

func clamp(v int32) int32 {
	switch {
	case v < 0:
		return 0
	case v > 255:
		return 255
	default:
		return v
	}
}

func calcDiff(a, b, out *Rgba) {
	for i := range a {
		out[i] = a[i] - b[i]
	}
}

func applyError(diff *Rgba, coef int32, inout *Rgba) {
	for i := range inout {
		inout[i] = clamp(inout[i] + diff[i]*coef/16)
	}
}

func correctPixel(img *BufImg, x, y, coef int32, diff *Rgba) {
	if img.IsInBounds(x, y) {
		ofs := img.Ofs(x, y)
		var tmp Rgba
		img.GetPixel(ofs, &tmp)
		applyError(diff, coef, &tmp)
		img.SetPixel(ofs, &tmp)
	}
}

func PixelDitherDo(img *BufImg, reducer *ColorReducer) {
	w := img.w
	h := img.h
	var rgba, rgbaReduced, rgbaDiff Rgba

	for y := int32(0); y < h; y++ {
		for x := int32(0); x < w; x++ {
			ofs := img.Ofs(x, y)
			img.GetPixel(ofs, &rgba)
			reducer.Closest(&rgba, &rgbaReduced)
			img.SetPixel(ofs, &rgbaReduced)
			calcDiff(&rgba, &rgbaReduced, &rgbaDiff)
			correctPixel(img, x-1, y+1, 3, &rgbaDiff)
			correctPixel(img, x, y+1, 5, &rgbaDiff)
			correctPixel(img, x+1, y+1, 1, &rgbaDiff)
			correctPixel(img, x+1, y, 7, &rgbaDiff)
		}
	}
}
