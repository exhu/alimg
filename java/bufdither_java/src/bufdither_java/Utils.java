/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package bufdither_java;

/**
 *
 * @author yur
 */
public class Utils {
    public static int nextPowerOfTwo(int n) {        
        n--;
        
        final int BIT_COUNT = 4*8;
        
        for (int i=1; i<BIT_COUNT; i<<=1) {
                n = n | (n >> i);
        }
        
        return n+1;
    }
    
    /**
     *
     * @param v integer value
     * @return bit count to represent value "v"
     */
    public static int bitsForInt(int v) {
        return 32-Integer.numberOfLeadingZeros(v);
    }
    
    
    // given 31 bits, 31 - 2 bits RGBA offset = 29 bits for address,
    // using 28 bits, so 28/2 = 14 bits max for x or y = 16384
    public static int swOfs(int x, int y, int xsizeBits) {
        // adressable bits depend on image size
        
        x &= 0x3FFF;
        y &= 0x3FFF;
        
        final int lowBits = 2;
        final int lowBitsMask = (1 << lowBits) - 1;
        
        int xMask = (x & lowBitsMask) | ((x >> lowBits) << (lowBits*2));
        int yMask = ((y & lowBitsMask) << lowBits) | ((y >> lowBits) << (xsizeBits + lowBits));
        int ofsV = (xMask | yMask) << 2; // shift for 2 bits rgba offset
        return ofsV;
    }
}
