using System;
using System.IO;

namespace bufdither_net
{
	public class BufImg : PixelProvider
	{
		private byte [] buf;
    	private int w,h;
		
		public BufImg ()
		{
			w = h = 0;
			buf = null;
		}
		
		public bool isInBounds (int x, int y)
		{
			return ((x > 0) && (x < w) && (y > 0) && (y < h));
		}

		public int getWidth ()
		{
			return w;
		}

		public int getHeight ()
		{
			return h;
		}

		public int ofs (int x, int y)
		{
			return (y*w + x)*4;
		}

		public void setPixelAt (int byteofs, int[] rgba)
		{
			for(int n = 0; n < 4; ++n)
            	buf[byteofs+n] = (byte)(rgba[n] & 0xFF);
		}

		public void getPixelAt (int byteofs, int[] rgba)
		{
			for(int n = 0; n < 4; ++n)
            	rgba[n] = (int)buf[byteofs+n] & 0xFF;
		}
		
		private int sz() {
        	return w*h*4;
    	}
		
		public void load(string fn)
		{
			BinaryReader reader = new BinaryReader(File.OpenRead(fn));
			
			w = reader.ReadInt32();
			h = reader.ReadInt32();
			
			buf = reader.ReadBytes(sz());
			
			reader.Close();
		}
		
		public void save(string fn)
		{
			BinaryWriter writer = new BinaryWriter(File.Open(fn, FileMode.Create));
			
			writer.Write(w);
			writer.Write(h);
			writer.Write(buf);
			writer.Close();
		}
	}
}

