/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package bufdither_java;

/**
 * swizzling using  Z-order/Morton order/Morton code
 * ...|y7|y6|y5|y4|y3|y2|...x7|x6|x5|x4|x3|x2|y1|y0|x1|x0|c1|c0|
 * i.e. 4x4 pixel tiles
 *
 * see http://fgiesen.wordpress.com/2011/01/17/texture-tiling-and-swizzling/
 * 
 * @author yur
 */
public class BufImgSwizzled extends BufImgTiled {
    private int xsizeBits;

    @Override
    protected void prepareOffsets() {
        xsizeBits = Utils.bitsForInt(getTiledWidth()-1);
    }
    
    
    
    // max 14-bit coords
    private int swOfs(int x, int y) {
        // adressable bits depend on image size
        
        return Utils.swOfs(x, y, xsizeBits);
    }

    @Override
    public int ofs(int x, int y) {
        return swOfs(x, y);
    }

    @Override
    public int ofsCol(int ofs, int colN) {
        return ofs | (colN & 3);
    }
    
    
    
}
