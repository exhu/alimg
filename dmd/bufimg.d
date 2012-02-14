module bufimg;
import std.stdio;

alias int [4] RGBA;

interface PixelProvider {
	bool isInBounds(int x, int y);
    
    int getWidth();
    int getHeight();
    /// returns false if x,y is out of bounds
    int ofs(int x, int y);   
    void setPixelAt(int byteofs, ref RGBA rgba);
    void getPixelAt(int byteofs, ref RGBA rgba);
}

public final class BufImg : PixelProvider {
    byte [] buf;
    int w,h;
    
    this() {
        w = 0;
        h = 0;
        buf = null;
    }
    
    void load(string fn) {
		auto f = File(fn, "rb");
		
		int [2] wh;
		
		f.rawRead(wh);
		
		w = wh[0];
		h = wh[1];
		
		buf = new byte[sz()];
		f.rawRead(buf);
    }
    
    void save(string fn) {
		auto f = File(fn, "wb");
		
		//int [2] wh = [w,h];
		
		f.rawWrite([w,h]);
		f.rawWrite(buf);
    }
    
    
    public int ofs(int x, int y) {
        return (y*w + x)*4;
    }
    
    private int sz() {
        return w*h*4;
    }
    
    
    public void setPixelAt(int byteofs, ref RGBA rgba) {
        for(int n = 0; n < 4; ++n)
            buf[byteofs+n] = cast(byte)(rgba[n] & 0xFF);
    }
    
    
    public void getPixelAt(int byteofs, ref RGBA rgba) {
        for(int n = 0; n < 4; ++n)
            rgba[n] = cast(int)buf[byteofs+n] & 0xFF;        
    }
    

    public int getWidth() {
        return w;
    }

    
    public int getHeight() {
        return h;
    }
    
    
    public bool isInBounds(int x, int y) {
        return ((x > 0) && (x < w) && (y > 0) && (y < h));
    }

    
}
