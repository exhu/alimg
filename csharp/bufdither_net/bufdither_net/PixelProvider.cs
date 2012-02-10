using System;

namespace bufdither_net
{
	public interface PixelProvider
	{
		bool isInBounds (int x, int y);
    
		int getWidth ();
		int getHeight ();
		/// returns false if x,y is out of bounds
		int ofs (int x, int y);   
		void setPixelAt (int byteofs, int [] rgba);
		void getPixelAt (int byteofs, int [] rgba);
	}
}

