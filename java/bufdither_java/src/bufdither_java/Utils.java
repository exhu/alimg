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
    
}
