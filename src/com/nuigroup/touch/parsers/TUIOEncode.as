package com.nuigroup.touch.parsers 
{
	import com.nuigroup.touch.ITouchParser;
	import com.nuigroup.touch.Touch;
	import com.nuigroup.touch.TouchCore;
	import com.nuigroup.touch.TouchManager;
	import com.nuigroup.touch.TouchProtocol;
	import flash.utils.IDataInput;
	/**
	 * 
	 * TUIO parser - not finished .
	 * 
	 * This is unfinished version .
	 * 
	 * 
	 * Tested on :
		 * Martin Kaltenbrunner (Reactivision) TUIOSimulator v1.4 .
	 * 
	 * 
	 * @author Gerard Sławiński || turbosqel
	 */
	public class TUIOEncode implements ITouchParser {
		
		public function TUIOEncode() {
			
		}
		
		public static var touchData:Object = new Object();
		
		public function get name():String {
			return TouchProtocol.TUIO;
		}
		
		public function get header():String {
			return "#bundle";
		}
		
		public static var sequence:uint;
		
		/**
		 * parse tuio message
		 * @param	raw
		 */
		public function parse(bytes:IDataInput):void {
			// tuio messages with this length are empty , so useless ...
			if (bytes.bytesAvailable == 44 || bytes.bytesAvailable == 48) {
				return;
			};
			//
			try {
				// check header
				if ("#bundle" == bytes.readUTFBytes(8)) {
					// message time values
					bytes.readUnsignedInt();// time
					bytes.readUnsignedInt();// time
					// number of touchs
					bytes.readInt();// length
					// message
					var message:String = getMSG(bytes);
					// params array
					var params:Array = readParams(getMSG(bytes) , bytes);
					params.shift();// remove type string
					// alive touch's :
					var alive:Array = params;
					//bytes.position += 4; //
					bytes.readByte();
					bytes.readByte();
					bytes.readByte();
					bytes.readByte();
				} else {
					trace("header error");
					return;
				};
				// get frame time
				var time:Number = (new Date).getTime();
				// loop on informations
				while (bytes.bytesAvailable) {
					if (bytes.readUTFBytes(1) == "/") {
						var type:String = getMSG(bytes , true);
						message = getMSG(bytes);
						params = readParams(message , bytes);
						switch(params[0]) {
							case "set":
								switch(type) {
									case "/tuio/2Dobj" :
										break;
									case "/tuio/2Dcur" :
										var id:int = params[1];
										var touch:Touch = touchData[id];
										if (touch) {
											touch.move(params[2] * TouchManager.width , params[3] * TouchManager.height);
										} else {
											touchData[id] = new Touch(id, params[2] * TouchManager.width, params[3] * TouchManager.height , time);
										};
										break;
									case "/tuio/2Dblb" :
										trace("read blob");
										break;
								};
								bytes.readByte();
								bytes.readByte();
								bytes.readByte();
								bytes.readByte();
								break;
								
							case "fseq":
								//
								sequence = params[1];
								break;
						}
					} else {
						trace("parseTUIO::invalid begin");
					};
				};
				
				
				
				for each (touch in touchData) {
					if (alive.indexOf(touch.id) == -1) {
						touchData[touch.id];
						touch.end(time);
					};
				};
				
				
			} catch (er:Error) {
				trace("encode error",er);
			};
		};
		
		
		protected static function readParams(pattern:String , bytes:IDataInput):Array {
			var params:Array = new Array();
			for (var c:int = 0; c < pattern.length; c++) {
				switch(pattern.charAt(c)){
					case "s": params.push(getMSG(bytes)); break;
					case "f": params.push(bytes.readFloat());break;
					case "i": params.push(bytes.readInt());break;
					case "d": params.push(bytes.readDouble());break;
					case "c": params.push(bytes.readMultiByte(4, "US-ASCII"));break;
					case "r": params.push(bytes.readUnsignedInt());break;
					default: break;
				}
			}
			return params;
			
		}
		
		protected static function getMSG(bytes:IDataInput , shorterBegin:Boolean = false):String {
			var out:String = "";
			while (bytes.bytesAvailable > 0) {
				if (shorterBegin) {
					var char:String = "/" + bytes.readUTFBytes(3);
					out += char;
					if (char.length < 4) break;
					shorterBegin = false;
				} else {
					char = bytes.readUTFBytes(4);
					out += char;
					if (char.length < 4) break;
				}
			};
			return out;
		}
		
		
	}

}