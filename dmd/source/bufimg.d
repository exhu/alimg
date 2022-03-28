module bufimg;
import std.stdio;

union Rgba {
    int [4] elems;
    int r,g,b,a;
}

public interface PixelProvider {
    int getWidth();
    int getHeight();
    /// returns false if x,y is out of bounds
    bool inBounds(int x, int y);
    int ofs(int x, int y);   
    void setPixelAt(int byteofs, Rgba rgba);
    Rgba getPixelAt(int byteofs);
}

public final class BufImg : PixelProvider {
    ubyte [] buf;
    int w,h;
    
    void load(string fn) {
        auto f = File(fn, "rb");
        
        int [2] wh;
        
        f.rawRead(wh);
        
        w = wh[0];
        h = wh[1];
        
        buf = new ubyte[sz()];
        f.rawRead(buf);
    }
    
    void save(string fn) {
        auto f = File(fn, "wb");
        f.rawWrite([w,h]);
        f.rawWrite(buf);
    }
    
    
    public override int ofs(int x, int y) {
        return (y*w + x)*4;
    }
    
    private int sz() {
        return w*h*4;
    }
    
    public override void setPixelAt(int byteofs, Rgba rgba) {
        foreach(n, e; rgba.elems)
            buf.ptr[byteofs+n] = cast(ubyte)(e & 0xFF);
    }
    
    public override Rgba getPixelAt(int byteofs) {
        Rgba rgba;
        foreach(n, ref e; rgba.elems)
            e = cast(int)buf.ptr[byteofs+n];
        return rgba;
    }
    
    public override int getWidth() {
        return w;
    }
    
    public override int getHeight() {
        return h;
    }
    
    public override bool inBounds(int x, int y) {
        return ((x >= 0) && (x < w) && (y >= 0) && (y < h));
    }
}
