/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package img2buf;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import javax.imageio.ImageIO;

/**
 *
 * @author yur
 */
public class Main {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws IOException {
        
        System.out.println("img2buf [-b] in out\n -b = convert from buf to png");
        
        if (!args[0].equals("-b"))
            Main.PngToBuf(args[0], args[1]);
        else
            Main.BufToPng(args[1], args[2]);
    }
    
    static void getPixel(BufferedImage img, int x, int y, int[] rgba) {
        int[] pixel = new int[4];
        // get pixel data
        img.getRaster().getPixel(x, y, pixel);
        // convert to RGBA
        img.getColorModel().getComponents(pixel, rgba, 0);
    }
    
    static void putPixel(BufferedImage img, int x, int y, int[] rgba) {
        byte[] elements = new byte[4];
        
        img.getColorModel().getDataElements(rgba, 0, elements);
        // put converted
        img.getRaster().setDataElements(x, y, elements);
    }
    
    static void WriteInt(OutputStream o, int i) throws IOException {
        for(int n = 0; n < 4; ++n) {
            o.write((i >> (n*8)) & 0xFF);
        }
    }
    
    static int ReadInt(InputStream o) throws IOException {
        int i = 0;
        for(int n = 0; n < 4; ++n) {
            i |= (o.read() << (n*8));
        }
        
        return i;
    }
    
    static void PngToBuf(String src, String dst) throws IOException {
        BufferedImage img;
     
        img = ImageIO.read(new File(src));
       
        
        int w,h;
        w = img.getWidth();
        h = img.getHeight();
        
        System.out.printf("image wxh = %d, %d\n", w, h);
        
        FileOutputStream fout;
       
        fout = new FileOutputStream(dst);
       
        WriteInt(fout, w);
        WriteInt(fout, h);
        
        int rgba[] = new int[4];
        
        for(int y = 0; y < h; ++y)
            for(int x = 0; x < w; ++x) {
                getPixel(img, x, y, rgba);
                
                for(int i = 0; i < 4; ++i)
                    fout.write(rgba[i]);
            }
       
        
        fout.close();
    }
    
    
    static void BufToPng(String src, String dst) throws IOException {        
        FileInputStream fin;
       
        fin = new FileInputStream(src);
       
        int w = ReadInt(fin);
        int h = ReadInt(fin);        
        
        System.out.printf("image wxh = %d, %d\n", w, h);
        
        BufferedImage img = new BufferedImage(w, h, BufferedImage.TYPE_4BYTE_ABGR);
        
        int rgba[] = new int[4];
        
        for(int y = 0; y < h; ++y)
            for(int x = 0; x < w; ++x) {
                for(int n = 0; n < 4; ++n) {
                    rgba[n] = fin.read();                    
                }
                
                putPixel(img, x, y, rgba);
            }
       
        
        fin.close();
        
        ImageIO.write(img, "png", new File(dst));
    }
}
