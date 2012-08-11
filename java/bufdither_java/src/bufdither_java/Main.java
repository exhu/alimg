/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package bufdither_java; 

import java.io.FileNotFoundException;
import java.io.IOException;

/**
 *
 * @author yur
 */
public class Main {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws FileNotFoundException, IOException {
        System.out.println("bufdither_java in.buf out.buf");
                
        reduce(args[0], args[1]);
    }
    
    static void reduce(String src, String dst) throws FileNotFoundException, IOException {
        BufImg img = new BufImgTiled();//new BufImg();
        img.load(src);
        
        PixelDither dither = new PixelDither();
        ColorReducer reducer = new ColorReducer(ColorReducer.PixelFormat.pf4444);
        
        
        for(int i = 0; i < 100; ++i) {
            dither.ditherImage(img, reducer);
        }
        
        
        
        img.save(dst);
        
    }
}
