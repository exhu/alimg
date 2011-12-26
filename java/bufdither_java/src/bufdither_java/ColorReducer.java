/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package bufdither_java;

/**
 *
 * @author Yury Benesh
 */
public class ColorReducer {

    public enum PixelFormat {

        pf4444,
        pf565,
        pf5551;
    }    
    

    public ColorReducer(PixelFormat targetPf) {
        this.targetPf = targetPf;
    }
    
    public final void reduceToClosest(int[] rgba, int[] destRGBA) {
        for (int i = 0; i < 4; ++i) {
            destRGBA[i] = downgradeComponent(rgba[i], i);
        }
    }
    
    //////////////////
    
    private static int downgrade(int a, int targetBitCount) {
        int maxv = ((1 << targetBitCount)-1);
        // ((a / 255.f) * maxv) / maxv * 255.f
        return a * maxv / 255 * 255 / maxv ;
    }
    
    private int downgradeComponent(int a, int cNum) {
        switch (targetPf) {
            case pf4444:
                return downgrade(a, 4);
                
            case pf565:
                if (cNum == 1)
                    return downgrade(a, 6);
                if ((cNum == 0) || (cNum == 2))
                    return downgrade(a, 5);

                break;

            case pf5551:
                if ((cNum >= 0) && (cNum <= 2))
                    return downgrade(a, 5);

                if (cNum == 3)
                    return downgrade(a, 1);
                
                break;

        }
        /// default for 4444
        //return a * 15 / 255 * 255 / 15;
        return 255;
    }

    
    private PixelFormat targetPf;
}
