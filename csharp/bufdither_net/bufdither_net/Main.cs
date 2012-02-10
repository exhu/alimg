using System;

namespace bufdither_net
{
	class MainClass
	{
		public static void Main (string[] args)
		{
			Console.WriteLine ("bufdither_net in.buf out.buf");
			reduce(args[0], args[1]);
		}
		
		static void reduce(String src, String dst)
		{
	        BufImg img = new BufImg();
	        img.load(src);
	        
	        PixelDither dither = new PixelDither();
	        ColorReducer reducer = new ColorReducer(ColorReducer.PixelFormat.pf4444);
	        
	        for(int i = 0; i < 100; ++i)
	            dither.ditherImage(img, reducer);
	        
	        img.save(dst);
	        
	    }
	}
}
