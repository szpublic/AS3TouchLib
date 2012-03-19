package com.nuigroup.touch.parsers {
	import com.nuigroup.touch.ITouchParser;
	import com.nuigroup.touch.TouchCore;
	import com.nuigroup.touch.TouchManager;
	import com.nuigroup.touch.TouchProtocol;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	
	/**
	 * ...
	 * @author Gerard Sławiński || turbosqel
	 */
	public class AutoCheck implements ITouchParser {
		
		public function AutoCheck() {
			
		}
		
		public function get name():String {
			return TouchProtocol.AUTO;
		}
		
		public function get header():String {
			return null;
		}
		
		
		public function parse(data:IDataInput):void {
			// first - copy message for reuse
			var read:ByteArray = new ByteArray();
			data.readBytes(read);
			read.endian = Endian.LITTLE_ENDIAN;
			data.endian = Endian.LITTLE_ENDIAN;
			
			// loop through message header
			for each (var parser:ITouchParser in TouchManager.parsers) {
				read.position = 0;
				var head:String = parser.header;
				if (head.length <= read.length && head == read.readUTFBytes(head.length)) {
					// same head , setup input mode
					TouchCore.parser = parser;
					break;
				};
			};
			// head not recognized , so parser function didnt change
			if (TouchCore.parser == this) {
				trace("unknown header");
				return;
			};
			// parser set , put again message to reader
			read.position = 0;
			TouchCore.parse(read);
		}
		
		
		
	}

}