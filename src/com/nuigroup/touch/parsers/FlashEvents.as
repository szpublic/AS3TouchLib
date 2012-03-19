package com.nuigroup.touch.parsers {
	import com.nuigroup.touch.ITouchParser;
	import com.nuigroup.touch.TouchCore;
	import com.nuigroup.touch.TouchManager;
	import com.nuigroup.touch.TouchProtocol;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.utils.IDataInput;
	
	/**
	 * ...
	 * @author Gerard Sławiński || turbosqel
	 */
	public class FlashEvents implements ITouchParser {
		
		public function FlashEvents() {
			
		}
		
		
		public function get name():String {
			return TouchProtocol.FLASHEVENT;
		}
		
		public function get header():String {
			return "FL";
		}
		
		public function parse(data:IDataInput):void {
			try {
				// check header
				if ("FL" != data.readUTFBytes(2)) {
					trace("invalid request , no FL header");
					return;
				};
				// number of touches
				var length:int = data.readShort();
				// touch position holder
				var pos:Point = new Point();
				for (var i:int = 0 ; i < length ; i++ ) {
					// read touch id
					var id:int = data.readByte();
					// read touch phase
					var phase:int = data.readByte();
					// read position (0-1) on stage ( x * stage.stageWidth )
					pos.x = data.readFloat() * TouchManager.width;
					pos.y = data.readFloat() * TouchManager.height;
					// read touch force
					var force:Number = data.readFloat();
					// dispatch on objects under point
					var objects:Array = TouchCore.getObjects(pos);
					// loop for each display object and dispatch event on accessables for mouse
					for each(var dsp:DisplayObject in objects) {
						TouchCore.dispatchEvent(phase , pos, dsp , id , force);
					};
				};
				
			} catch (er:Error) {
				trace("parse error:FlashEvents");
			};
			// write left bytes from stream
			while (data.bytesAvailable) {
				data.readByte();
			};
		};
		
	}

}