package com.nuigroup.touch.parsers 
{
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
	public class FlashXML implements ITouchParser 
	{
		
		public function FlashXML() {
			
		}
		
		public static var Timeout:int = 350;
		
		public function get name():String {
			return TouchProtocol.FLASHXML;
		}
		
		public function get header():String {
			return "<OSCPACKET";
		}
		
		public var touchData:Object = new Object();
		
		protected var interval:Number;
		
		public function parse(data:IDataInput):void {
			try {
				// actual time
				var time:Number = (new Date).getTime();
				
				// new index
				var newStack:Object = new Object();
				/////////////////////////
				// encode XML with data
				var xml:XML = XML(data.readUTFBytes(data.bytesAvailable));
				// get touchs as children
				var msg:XMLList = xml.children();
				// loop for each touch
				for each(var info:XML in msg) {
					// touch params
					var params:XMLList = info.children();
					// touch data always have 7 params , its quick way to check for correct child
					if (params.length() == 7) {
						// touch id
						var id:int = int(params[1].@VALUE);
						// check if touch exist
						var touch:Touch = touchData[id];
						if (touch) {
							// touch exist , so we call move function
							touch.move(Number(params[2].@VALUE) * TouchManager.width , Number(params[3].@VALUE) * TouchManager.height );
							// and remove from old index
							touchData[id] = null;
						}else {
							// create new touch
							touch = new Touch( id , Number(params[2].@VALUE) * TouchManager.width , Number(params[3].@VALUE) * TouchManager.height  , time );
						};
						// read force param
						touch.force = Number(params[6].@VALUE);
						// touch add to new index
						newStack[id] = touch;
					};
				};
				// remove untracked touchs
				for each(touch in touchData) {
					if (touch) {
						touch.end(time);
					};
				};
				// setup new stack
				touchData = newStack;
			}catch (er:Error) {
				trace("read error: " ,er,er.getStackTrace());
			};
			// timeout interval
			if(!isNaN(interval)){
				clearInterval(interval);
			};
			interval = setTimeout(clearTouchs, Timeout);
		}
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