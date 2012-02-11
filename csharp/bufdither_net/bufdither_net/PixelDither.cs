using System;

namespace bufdither_net
{
	public unsafe class PixelDither
	{
		public PixelDither ()
		{
		}
		
		private RGBA rgbaDiff;
		private PixelProvider img;
		private RGBA rgbaTemp;
    
		public void ditherImage (PixelProvider img, ColorReducer cr)
		{        
			this.img = img;
			int w = img.getWidth ();        
			int h = img.getHeight ();
			RGBA rgba = new RGBA();
			RGBA rgbaReduced = new RGBA();
			int ofs;
        
			//final int lastRow = h-1;
			//final int lastColumn = w-1;
        
        
			for (int y = 0; y < h; ++y)
				for (int x = 0; x < w; ++x) {
					ofs = img.ofs (x, y);
					img.getPixelAt (ofs, ref rgba);
					cr.reduceToClosest (ref rgba, ref rgbaReduced);
					img.setPixelAt (ofs, ref rgbaReduced);
                
                
					calcDiff (ref rgba, ref rgbaReduced);
                
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
				img.getPixelAt (ofs, ref rgbaTemp);
				adjustTemp (coef);
				img.setPixelAt (ofs, ref rgbaTemp);
			}
		}
    
		private void adjustTemp (int coef)
		{
			fixed(int * prgbaTemp = rgbaTemp.rgba, prgbaDiff = rgbaDiff.rgba)
			{
				for (int i = 0; i < 4; ++i) {
					prgbaTemp[i] = prgbaTemp[i] + prgbaDiff[i] * coef / 16;
					prgbaTemp[i] = clamp (prgbaTemp[i]);
				}
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
    
		private void calcDiff (ref RGBA rgba, ref RGBA rgbaReduced)
		{
			fixed(int * prgbaDiff = rgbaDiff.rgba, prgba = rgba.rgba, prgbaReduced = rgbaReduced.rgba)
			{
			for (int n = 0; n < 4; ++n) {
				prgbaDiff[n] = prgba [n] - prgbaReduced[n];
			}
			}
		}

	}
}

