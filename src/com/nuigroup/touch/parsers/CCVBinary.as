package com.nuigroup.touch.parsers {
	import com.nuigroup.touch.ITouchParser;
	import com.nuigroup.touch.Touch;
	import com.nuigroup.touch.TouchCore;
	import com.nuigroup.touch.TouchManager;
	import com.nuigroup.touch.TouchProtocol;
	import flash.utils.clearInterval;
	import flash.utils.IDataInput;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author Gerard Sławiński || turbosqel
	 */
	public class CCVBinary implements ITouchParser {
		
		public function CCVBinary() {
			
		}
		
		public var touchData:Object = new Object();
		
		public function get name():String {
			return TouchProtocol.CCVINPUT;
		}
		
		public function get header():String {
			return "CCV";
		}
		
		
		/**
		 * ccv timeout delay
		 */
		public static var CCVTimeout:int = 350;
		
		/**
		 * clear touch interval , when delay between sending data is too long
		 */
		protected var interval:Number;
		
		public function parse(data:IDataInput):void {
			try {
				// check header
				if ("CCV" != data.readUTFBytes(4)) {
					trace("invalid request , no CCV header");
					return;
				};
				// touchs number
				var length:int = data.readInt();
				// get actual time
				var time:Number = (new Date).getTime();
				// recived touchs index
				var newStack:Object = new Object();
				
				//// data read loop
				for (var i:int ; i < length ; i++ ) {
					// get touch id
					var id:int = data.readInt();
					// check if touch exist in our index
					var touch:Touch = touchData[id];
					if (touch) {
						// exist , so we move it to new location
						touch.move(data.readFloat() * TouchManager.width , data.readFloat() * TouchManager.height );
						// and remove it from old index
						touchData[id] = null;
					}else {
						// not exist , so we create new touch instance
						touch = new Touch( id , data.readFloat() * TouchManager.width , data.readFloat() * TouchManager.height , time );
					};
					// add touch to new index
					newStack[id] = touch;
					// 2 floats about last x,y position are not neccessary , because Touch instance do it automaticly
					data.readFloat();// touch.last.x
					data.readFloat();//touch.last.y 
					// additional touch value , depends on source it can be pressure or touch size
					touch.force = data.readFloat();
				};
				// remove old touchs , dispatch end event
				for each(touch in touchData) {
					if (touch) {
						touch.end(time);
					};
				};
				// replace index
				touchData = newStack;
			}catch (er:Error) {
				trace("read error: " ,er,er.getStackTrace());
			};
			// read rest of data (to not left bytes in socket)
			while (data.bytesAvailable) {
				data.readByte();
			};
			// lost connection timeout - if next CCV package will not be send because connection or similar things
			// touches are cleared automaticly
			if(!isNaN(interval)){
				clearInterval(interval);
			};
			// set timeout for next package
			interval = setTimeout(clearTouchs, CCVTimeout);
		};
		
		
		public function clearTouchs():void {
			// actual time
			var time:Number = (new Date).getTime();
			// loop for each touch and end it
			for each( var touch:Touch in touchData) {
				if (touch) {
					touch.end(time);
				};
			};
			touchData = new Object();
		};
		
	}

}