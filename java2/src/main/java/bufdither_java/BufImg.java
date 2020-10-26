package bufdither_java;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

/**
 *
 * @author yur
 */
public final class BufImg implements PixelProvider {
    byte buf[];
    int w,h;
    
    BufImg() {
        w = 0;
        h = 0;
        buf = null;
    }
    
    BufImg(int w, int h) {
        this.w = w;
        this.h = h;
        buf = new byte[sz()];
    }
    
    void load(String fn) throws FileNotFoundException, IOException {
        FileInputStream fin = new FileInputStream(fn);
        
        w = readInt(fin);
        h = readInt(fin);
        
        buf = new byte[sz()];
        
        fin.read(buf);
        
        fin.close();        
    }
    
    void save(String fn) throws FileNotFoundException, IOException {
        FileOutputStream fout = new FileOutputStream(fn);
        writeInt(fout, w);
        writeInt(fout, h);
        fout.write(buf);
        fout.close();
    }
    
    @Override
    public int ofs(int x, int y) {
        return (y*w + x)*4;
    }
    
    private int sz() {
        return w*h*4;
    }
    
    @Override
    public void setPixelAt(int byteofs, int rgba[]) {
        for(int n = 0; n < 4; ++n)
            buf[byteofs+n] = (byte)(rgba[n] & 0xFF);
    }
    
    @Override
    public void getPixelAt(int byteofs, int rgba[]) {
        for(int n = 0; n < 4; ++n)
            rgba[n] = (int)buf[byteofs+n] & 0xFF;        
    }
    
    //////
    @Override
    public int getWidth() {
        return w;
    }

    @Override
    public int getHeight() {
        return h;
    }
    
    @Override
    public boolean isInBounds(int x, int y) {
        return ((x > 0) && (x < w) && (y > 0) && (y < h));
    }

    
    //////
    private static void writeInt(OutputStream o, int i) throws IOException {
        for(int n = 0; n < 4; ++n) {
            o.write((i >> (n*8)) & 0xFF);
        }
    }
    
    private static int readInt(InputStream o) throws IOException {
        int i = 0;
        for(int n = 0; n < 4; ++n) {
            i |= (o.read() << (n*8));
        }
        
        return i;
    }


    
}
