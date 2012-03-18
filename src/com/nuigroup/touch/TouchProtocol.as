package com.nuigroup.touch{
	public class TouchProtocol{
		/**
		 * 
		 * endian = LITTLE_ENDIAN
		 * operation // bytes
		 * 
		 * header:
		 * writeUTFBytes("CCV")		// 3
		 * writeByte(0)				// 1
		 * writeInt(numTouchs)		// 4
		 * loop :
		 * writeInt(id)				// 4
		 * writeFloat(x)			// 4
		 * writeFloat(y)			// 4
		 * writeFloat(lastX)		// 4
		 * writeFloat(lastY)		// 4
		 * writeFloat(acceleration)	// 4
		 * 
		 */
		public static const CCVINPUT:String = "ccvbinary";
		
		/**
		 * 
		 * endian = LITTLE_ENDIAN
		 * operation 				// bytes
		 * 
		 * header:
		 * writeUTFBytes("FL") 		// 2
		 * writeShort(numTouchs)	// 2 
		 * loop:
		 * writeByte(id) 			// 2 (touch num)
		 * writeByte(phase)			// 2 (phase 0-down , 2-move , 4-up , 5-tap)
		 * writeFloat(x) 			// 4 ( x position in 0-1 value )
		 * writeFloat(y) 			// 4 ( y position in 0-1 value )
		 * writeFload(pressure)		// 4 ( force in 0-1 value )
		 * 
		 */
		public static const FLASHEVENT:String = "flashtouchevent";
		
		
		/**
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 */
		public static const FLASHXML:String = "flashXML";
		
		
		/**
		 * 
		 * 
		 * 
		 * 
		 * 
		 */
		public static const TUIO:String = "tuioOSC";
		
		
		public static const AUTO:String = "autoChoose";
	}
}