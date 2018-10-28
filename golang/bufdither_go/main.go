package main

import (
	"fmt"
	"os"
)

func main() {
	if len(os.Args) != 3 {
		fmt.Println("usage: bufdither_go src.buf dst.buf")
		os.Exit(1)
	}

	const cycles = 100

	buf := BufImg{}
	buf.Load(os.Args[1])
	fmt.Println("image size = %i, %i", buf.w, buf.h)

	reducer := ColorReducer{}
	reducer.Init()

	for i := 0; i < cycles; i++ {
		PixelDitherDo(&buf, &reducer)
	}

	buf.Save(os.Args[2])
}
