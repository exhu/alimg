package main

func clamp(v int) int {
	switch {
	case v < 0:
		return 0
	case v > 255:
		return 255
	default:
		return v
	}
}

func calcDiff(a, b Rgba) (out Rgba) {
	for i := range a {
		out[i] = a[i] - b[i]
	}
	return out
}

func applyError(diff Rgba, coef int, inout *Rgba) {
	for i := range inout {
		inout[i] = clamp(inout[i] + diff[i]*coef/16)
	}
}

func correctPixel(img *BufImg, x, y, coef int, diff Rgba) {
	if img.IsInBounds(x, y) {
		ofs := img.Ofs(x, y)
		tmp := img.GetPixel(ofs)
		applyError(diff, coef, &tmp)
		img.SetPixel(ofs, tmp)
	}
}

func PixelDitherDo(img *BufImg, reducer *ColorReducer) {
	w := int(img.w)
	h := int(img.h)
	var rgba, rgbaReduced, rgbaDiff Rgba

	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			ofs := img.Ofs(x, y)
			rgba = img.GetPixel(ofs)
			rgbaReduced = reducer.Closest(rgba)
			img.SetPixel(ofs, rgbaReduced)
			rgbaDiff = calcDiff(rgba, rgbaReduced)
			correctPixel(img, x-1, y+1, 3, rgbaDiff)
			correctPixel(img, x, y+1, 5, rgbaDiff)
			correctPixel(img, x+1, y+1, 1, rgbaDiff)
			correctPixel(img, x+1, y, 7, rgbaDiff)
		}
	}
}
