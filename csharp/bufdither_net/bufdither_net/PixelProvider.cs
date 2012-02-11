using System;

namespace bufdither_net
{
	public unsafe struct RGBA
	{
		public fixed int rgba[4];
	}
	
	public unsafe interface PixelProvider
	{
		bool isInBounds (int x, int y);
    
		int getWidth ();
		int getHeight ();
		/// returns false if x,y is out of bounds
		int ofs (int x, int y);   
		void setPixelAt (int byteofs, ref RGBA rgba);
		void getPixelAt (int byteofs, ref RGBA rgba);
	}
}

