package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"runtime"
	"runtime/pprof"
)

func doWork(src, dst string) {
	const cycles = 100

	buf := BufImg{}
	buf.Load(src)
	fmt.Println("image size = %i, %i", buf.w, buf.h)

	reducer := ColorReducer{}
	reducer.Init()

	for i := 0; i < cycles; i++ {
		PixelDitherDo(&buf, &reducer)
	}

	buf.Save(dst)
}

var cpuprofile = flag.String("cpuprofile", "", "write cpu profile to `file`")
var memprofile = flag.String("memprofile", "", "write memory profile to `file`")

func main() {
	flag.Parse()

	args := flag.Args()
	if len(args) != 2 {
		fmt.Println("usage: bufdither_go src.buf dst.buf")
		os.Exit(1)
	}

	if *cpuprofile != "" {
		f, err := os.Create(*cpuprofile)
		if err != nil {
			log.Fatal("could not create CPU profile: ", err)
		}
		if err := pprof.StartCPUProfile(f); err != nil {
			log.Fatal("could not start CPU profile: ", err)
		}
		defer pprof.StopCPUProfile()
	}

	doWork(args[0], args[1])

	if *memprofile != "" {
		f, err := os.Create(*memprofile)
		if err != nil {
			log.Fatal("could not create memory profile: ", err)
		}
		runtime.GC() // get up-to-date statistics
		if err := pprof.WriteHeapProfile(f); err != nil {
			log.Fatal("could not write memory profile: ", err)
		}
		f.Close()
	}
}
