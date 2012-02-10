using System;

namespace bufdither_net
{
	public class ColorReducer
	{
		delegate int Downgrade (int a, int cNum);
		
		public enum PixelFormat
		{
			pf4444,
			pf565,
			pf5551
		}
		
		private Downgrade downgr;
		
		public ColorReducer (PixelFormat targetPf)
		{
			initLookups ();
			switch (targetPf) {
			case PixelFormat.pf4444:
				downgr = (int a, int cNum) => {
					//return downgrade(a, 4);
					return lookup4 [a];
				};
				break;


			case PixelFormat.pf565:
				downgr = (int a, int cNum) => {
					if (cNum == 1) {
						return downgrade (a, 6);
					}
					if ((cNum == 0) || (cNum == 2)) {
						return downgrade (a, 5);
					}

					return 255;
				};
				break;

			case PixelFormat.pf5551:
				downgr = (int a, int cNum) => {
					if ((cNum >= 0) && (cNum <= 2)) {
						return downgrade (a, 5);
					}

					if (cNum == 3) {
						return downgrade (a, 1);
					}
					return 255;
				};

				break;
			}
		}
		
		public void reduceToClosest (int[] rgba, int[] destRGBA)
		{
			for (int i = 0; i < 4; ++i) {
				destRGBA [i] = downgr (rgba [i], i);
			}
		}

		//////////////////
		private static int downgrade (int a, int targetBitCount)
		{
			int maxv = ((1 << targetBitCount) - 1);
			// ((a / 255.f) * maxv) / maxv * 255.f
			return a * maxv / 255 * 255 / maxv;
		}
    
		private static int[] lookup4 = new int[256];

		private static void initLookups ()
		{
			for (int i = 0; i < 256; ++i) {
				lookup4 [i] = downgrade (i, 4);
			}
		}
	}
}

