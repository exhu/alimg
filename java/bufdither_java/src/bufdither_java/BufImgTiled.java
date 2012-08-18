/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package bufdither_java;

import java.io.FileNotFoundException;
import java.io.IOException;

/** Image representation using tiles.
 *
 * @author yur
 */
public class BufImgTiled extends BufImg {
    // 4 bytes per pixel * 4 pixels = 16 bytes, 16*4 = 64 bytes,
    // more chances for cache hit
    final static int TILE_SIZE_PX = 4;
    final static int TILE_SIZE_BYTES = TILE_SIZE_PX * TILE_SIZE_PX * 4;
    
    private int tiledW = 0, tiledH = 0, tilesW = 0, tilesH = 0;
    private byte tiledBuf[];
    
    protected int getTiledWidth() {
        return tiledW;
    }
    
    /// override to prepare to calculate offsets etc., called in makeTiled
    /// just after the tiled buffer is created
    protected void prepareOffsets() {
        // Nothing to do there
    }
    
    @Override
    public void load(String fn) throws FileNotFoundException, IOException {
        super.load(fn);
        makeTiled();
    }

    @Override
    public void save(String fn) throws FileNotFoundException, IOException {
        untile();
        super.save(fn);
    }
    
    private int tiledOfs(int x, int y) {
        
        int tileX = x / TILE_SIZE_PX;
        int tileY = y / TILE_SIZE_PX;
        int inTileX = x % TILE_SIZE_PX;
        int inTileY = y % TILE_SIZE_PX;
        
        return (tileY * tilesW + tileX)*TILE_SIZE_BYTES + inTileY * TILE_SIZE_PX * 4 + inTileX * 4;
    }
    
    private void makeTiled() {
        tiledW = Utils.nextPowerOfTwo(getWidth());
        tiledH = Utils.nextPowerOfTwo(getHeight());
        
        tilesW = tiledW / TILE_SIZE_PX;
        tilesH = tiledH / TILE_SIZE_PX;
        
        tiledBuf = new byte[tiledW*tiledH*4];
        
        prepareOffsets();
        
        int bufOfs = 0;
        
        for(int y = 0; y < getHeight(); ++y) {
            for (int x = 0; x < getWidth(); ++x, bufOfs += 4) {
                int ofs = ofs(x,y);
                for(int b = 0; b < 4; ++b) {
                    try {
                        tiledBuf[ofsCol(ofs, b)] = buf[bufOfs+b];
                    }
                    catch(ArrayIndexOutOfBoundsException e) {
                        System.out.println("got!");
                    }
                }
            }
        }
    }
    
    private void untile() {
        int bufOfs = 0;
        
        for(int y = 0; y < getHeight(); ++y) {
            for (int x = 0; x < getWidth(); ++x, bufOfs += 4) {
                int ofs = ofs(x,y);
                for(int b = 0; b < 4; ++b) {
                    buf[bufOfs+b] = tiledBuf[ofsCol(ofs, b)];
                }
            }
        }
    }

    @Override
    public int ofs(int x, int y) {
        return tiledOfs(x, y);
    }
    
    public int ofsCol(int ofs, int colN) {
        return ofs + colN;
    }

    @Override
    public void setPixelAt(int byteofs, int[] rgba) {
        for(int b = 0; b < 4; ++b) {
            tiledBuf[byteofs + b] = (byte)(rgba[b] & 0xFF);
        }
    }

    @Override
    public void getPixelAt(int byteofs, int[] rgba) {
        for(int b = 0; b < 4; ++b) {
            rgba[b] = (int)tiledBuf[byteofs + b] & 0xFF;
        }
    }
    
    
    
}
