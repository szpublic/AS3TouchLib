package com.nuigroup.touch.emulator {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import com.nuigroup.touch.TouchCore;
	/**
	 * ...
	 * @author Gerard Sławiński || turbosqel
	 */
	public class Emulator {
		
		public static function emulateCCVTouch(id:int = 0 , posX:Number = 0 , posY:Number = 0 ):void {
			var ba:ByteArray = new ByteArray();
			ba.endian = Endian.LITTLE_ENDIAN;
			ba.writeUTFBytes("CCV");
			ba.writeByte(0);
			ba.writeInt(1);
			ba.writeInt(id);
			ba.writeFloat(posX);
			ba.writeFloat(posY);
			ba.writeFloat(0);
			ba.writeFloat(0);
			ba.writeFloat(0);
			ba.position = 0;
			TouchCore.parse(ba);
		};
		
	}

}