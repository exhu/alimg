using System;

namespace bufdither_net
{
	public class PixelDither
	{
		public PixelDither ()
		{
		}
		
		private int[] rgbaDiff = new int[4];
		private PixelProvider img;
		private int[] rgbaTemp = new int[4];
    
		public void ditherImage (PixelProvider img, ColorReducer cr)
		{        
			this.img = img;
			int w = img.getWidth ();        
			int h = img.getHeight ();
			int [] rgba = new int[4];
			int [] rgbaReduced = new int[4];
			int ofs;
        
			//final int lastRow = h-1;
			//final int lastColumn = w-1;
        
        
			for (int y = 0; y < h; ++y)
				for (int x = 0; x < w; ++x) {
					ofs = img.ofs (x, y);
					img.getPixelAt (ofs, rgba);
					cr.reduceToClosest (rgba, rgbaReduced);
					img.setPixelAt (ofs, rgbaReduced);
                
                
					calcDiff (rgba, rgbaReduced);
                
					//////////////////////////
					// order, apply error to original pixels
					// (x-1,y+1) = 3/16 , (x,y+1) = 5/16, (x+1,y+1) = 1/16, (x+1, y)=7/16
                
                
					correctPixel (x - 1, y + 1, 3);
					correctPixel (x, y + 1, 5);
					correctPixel (x + 1, y + 1, 1);                
					correctPixel (x + 1, y, 7);                                 
				}
        
        
			// no longer need img
			this.img = null;
		}
    
		private void correctPixel (int x, int y, int coef)
		{
			if (img.isInBounds (x, y)) {
				int ofs = img.ofs (x, y);
				img.getPixelAt (ofs, rgbaTemp);
				adjustTemp (coef);
				img.setPixelAt (ofs, rgbaTemp);
			}
		}
    
		private void adjustTemp (int coef)
		{
			for (int i = 0; i < 4; ++i) {
				rgbaTemp [i] = rgbaTemp [i] + rgbaDiff [i] * coef / 16;
				rgbaTemp [i] = clamp (rgbaTemp [i]);
			}            
		}
    
		private static int clamp (int v)
		{
			if (v < 0)
				return 0;
        
			if (v > 255)
				return 255;
        
			return v;
		}
    
		private void calcDiff (int [] rgba, int [] rgbaReduced)
		{
			for (int n = 0; n < 4; ++n) {
				rgbaDiff [n] = rgba [n] - rgbaReduced [n];
			}
		}

	}
}

