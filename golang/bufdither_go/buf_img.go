package main

import (
	"fmt"
	"math"
	"os"
)

type BufImg struct {
	buf  []byte
	w, h int32
}

type Rgba [4]int

func readInt32(f *os.File) int32 {
	var int32v [4]byte
	cnt, err := f.Read(int32v[:])
	if err == nil {
		if cnt != len(int32v) {
			panic("broken file")
		}
	} else {
		panic(err)
	}
	return int32(int32v[0]) | int32(int32v[1])<<8 | int32(int32v[2])<<16 | int32(int32v[3])<<24
}

func writeInt32(f *os.File, value int32) {
	var int32v [4]byte
	int32v[0] = byte(value & 0xFF)
	int32v[1] = byte(value >> 8 & 0xFF)
	int32v[2] = byte(value >> 16 & 0xFF)
	int32v[3] = byte(value >> 24 & 0xFF)
	cnt, err := f.Write(int32v[:])
	if err != nil {
		panic(err)
	}
	if cnt != len(int32v) {
		panic("could not write to file")
	}
}

func (img *BufImg) Load(fn string) {
	f, err := os.Open(fn)
	if err == nil {
		img.w = readInt32(f)
		img.h = readInt32(f)
		var imgSz = img.w * img.h * 4
		fmt.Printf("imgSz = %d\n", imgSz)
		if imgSz > math.MaxInt32 || imgSz <= 0 {
			panic(fmt.Sprintf("image size is invalid = %d", imgSz))
		}
		img.buf = make([]byte, imgSz)
		cnt, err := f.Read(img.buf)
		if err != nil {
			panic(err)
		}
		if cnt != int(imgSz) {
			panic("image size doesn't match bytes read")
		}
	} else {
		panic(err)
	}

	f.Close()
}

func (img *BufImg) Save(fn string) {
	f, err := os.Create(fn)
	if err == nil {
		writeInt32(f, img.w)
		writeInt32(f, img.h)
		cnt, err := f.Write(img.buf)
		if err != nil {
			panic(err)
		}
		if cnt != len(img.buf) {
			panic("failed to write file")
		}
	} else {
		panic(err)
	}
	f.Close()
}

func (img *BufImg) Ofs(x, y int) int {
	return int(img.w)*y*4 + x*4
}

func (img *BufImg) IsInBounds(x, y int) bool {
	return (x >= 0) && (x < int(img.w)) && (y >= 0) && (y < int(img.h))
}

func (img *BufImg) SetPixel(ofs int, value *Rgba) {
	for i := 0; i < 4; i++ {
		img.buf[ofs+i] = byte(value[i] & 0xFF)
	}
}

func (img *BufImg) GetPixel(ofs int, value *Rgba) {
	for i := 0; i < 4; i++ {
		value[i] = int(img.buf[ofs+i])
	}
}
