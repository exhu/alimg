import std.stdio;
import bufimg;
import ditherproc;

void main(string [] args) {
	writeln("bufdither_dmd src.buf dst.buf");
	reduce(args[1], args[2]);
}


void reduce(string src, string dst) {
	BufImg img = new BufImg();
	img.load(src);
	
	PixelDither dither = new PixelDither();
	ColorReducer reducer = new ColorReducer(ColorReducer.PixelFormat.pf4444);
	
	//for(int i = 0; i < 100; ++i)
	dither.ditherImage(img, reducer);
	
	img.save(dst);
}
