package com.nuigroup.touch {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.IDataInput;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author Gerard Sławiński || turbosqel
	 */
	public class TouchCore {
		
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- PARSING
		
		/**
		 * clear touch interval , when delay between sending data is too long
		 */
		protected static var interval:Number;
		
		public static var CCVTimeout:int = 200;
		
		/**
		 * object contain touch's data
		 */
		public static var touchData:Object = new Object();
		
		/**
		 * parse bytes to Touch data
		 * @param	data		IDataInput element , like Socket or ByteArray
		 */
		public static function parse(data:IDataInput):void {
			parser(data);
		};
		
		/**
		 * parser function
		 */
		public static var parser:Function = parseCheck;
		
		/**
		 * recive data from socket and parse
		 * @param	e
		 */
		internal static function reciveData(e:ProgressEvent):void {
			parse(e.target as Socket);
		};
		
		
		/**
		 * function that read header , check for data type and switch to correct encoding function
		 * @param	data		IDataInput element
		 */
		public static function parseCheck(data:IDataInput):void {
			var read:ByteArray = new ByteArray();
			data.readBytes(read);
			read.position = 0;
			
			for (var head:String in TouchManager.headers) {
				if (head == read.readUTFBytes(head.length)) {
					TouchManager.inputMode = TouchManager.headers[head];
					break;
				};
				read.position = 0;
			};
			
			read.position = 0;
			parser(read);
			
		};
		
		/**
		 * function for parse TCP-CCV data
		 * @param	data
		 */
		public static function parseCCV(data:IDataInput):void {
			try {
				if ("CCV" != data.readUTFBytes(4)) {
					trace("invalid request , no CCV header");
					return;
				};
				var recived:Object = new Object();
				var length:int = data.readInt();
				var time:Number = (new Date).getTime();
				var newStack:Object = new Object();
				for (var i:int ; i < length ; i++ ) {
					var id:int = data.readInt();
					var touch:Touch = touchData[id];
					if (touch) {
						touch.move(data.readFloat() * TouchManager.width , data.readFloat() * TouchManager.height );
						touchData[id] = null;
					}else {
						touch = new Touch( id , data.readFloat() * TouchManager.width , data.readFloat() * TouchManager.height , time );
					};
					newStack[id] = touch;
					touch.last.x = data.readFloat();
					touch.last.y = data.readFloat();
					touch.force = data.readFloat();
				};
				for each(touch in touchData) {
					if (touch) {
						touch.end(time);
					};
				};
				touchData = newStack;
			}catch (er:Error) {
				trace("read error: " ,er,er.getStackTrace());
			};
			while (data.bytesAvailable) {
				data.readByte();
			};
			if(!isNaN(interval)){
				clearInterval(interval);
			};
			interval = setTimeout(clearTouch, CCVTimeout);
		};
		
		/**
		 * clear CCV touch data
		 */
		public static function clearTouch():void {
			var time:Number = (new Date).getTime();
			for each( var touch:Touch in touchData) {
				if (touch) {
					touch.end(time);
				};
			};
			for (var key:String in touchData) {
				delete touchData[key];
			};
		};
		
		
		/**
		 * parse flash events binary data
		 * @param	data
		 */
		public static function parseFlashEvent(data:IDataInput):void {
			try {
				if ("FL" != data.readUTFBytes(2)) {
					trace("invalid request , no FL header");
					return;
				};
				var length:int = data.readShort();
				var pos:Point = new Point();
				for (var i:int = 0 ; i < length ; i++ ) {
					var id:int = data.readByte();
					var phase:int = data.readByte();
					pos.x = data.readFloat() * TouchManager.width;
					pos.y = data.readFloat() * TouchManager.height;
					var force:Number = data.readFloat();
					// dispatch :
					var objects:Array = getObjects(pos);
					for each(var dsp:DisplayObject in objects) {
						if(mouseEnabled(dsp)){
							var local:Point = dsp.globalToLocal(pos); 
							dispatchEvent(phase , local, dsp , id , force);
						};
					};
				};
				
			} catch (er:Error) {
				trace("parse error:FlashEvents");
			};
			while (data.bytesAvailable) {
					data.readByte();
			};
		};
		
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- EVENTS DISPATCHING
		
		/**
		 * touch down event
		 */
		public static const DOWN:int = 0;
		/**
		 * touch over object event
		 */
		public static const OVER:int = 1;
		/**
		 * touch move event
		 */
		public static const MOVE:int = 2;
		/**
		 * touch out from object event
		 */
		public static const OUT:int = 3
		/**
		 * touch end/finger up event
		 */
		public static const UP:int = 4;
		/**
		 * tap/click event
		 */
		public static const TAP:int = 5;
		
		/**
		 * output function to dispach event .
		 * Function scheme : f(phase:int , point:Point , target:DisplayObject , id:int, force:Number):void
		 */
		public static var EventDelegate:Function;
		
		/**
		 * dispatch output Event on selected object , if target is accessable for mouse
		 * @param	phase			event phase
		 * @param	point			event position
		 * @param	target			target displayobject
		 * @param	id				touch id
		 * @param	force			for TouchEvent - pressure
		 */
		public static function dispatchEvent(phase:int , point:Point , target:DisplayObject , id:int = 0 , force:Number = 0):void {
			if(mouseEnabled(target)){
				EventDelegate(phase , point , target , id , force);
			};
		};
		
		/**
		 * dipatch touch Event on target object
		 * @param	phase			event phase
		 * @param	point			touch position
		 * @param	target			target object
		 * @param	id				touch id
		 * @param	force			pressure
		 */
		public static function dispatchTouchEvent(phase:int , point:Point , target:DisplayObject , id:int, force:Number):void {
			switch(phase) {
				case DOWN:
					var type:String = TouchEvent.TOUCH_BEGIN;
					break;
				case OVER :
					type = TouchEvent.TOUCH_OVER;
					break;
				case MOVE :
					type = TouchEvent.TOUCH_MOVE;
					break;
				case OUT :
					type = TouchEvent.TOUCH_OUT;
					break;
				case UP :
					type = TouchEvent.TOUCH_END;
					break;
				case TAP :
					type = TouchEvent.TOUCH_TAP;
					break;
			};
			var local:Point = target.globalToLocal(point);
			target.dispatchEvent(new TouchEvent(type , true , true , id, false , local.x , local.y , NaN , NaN , force));
		};
		
		/**
		 * dispatch mouse event on target object
		 * @param	phase			event phase
		 * @param	point			touch position
		 * @param	target			target displayobject
		 * @param	id				N/A
		 * @param	force			N/A
		 */
		public static function dispatchMouseEvent(phase:int , point:Point , target:DisplayObject , id:int, force:Number):void {
			switch(phase) {
				case DOWN:
					var type:String = MouseEvent.MOUSE_DOWN;
					break;
				case OVER :
					type = MouseEvent.MOUSE_OVER;
					break;
				case MOVE :
					type = MouseEvent.MOUSE_MOVE;
					break;
				case OUT :
					type = MouseEvent.MOUSE_OUT;
					break;
				case UP :
					type = MouseEvent.MOUSE_UP;
					break;
				case TAP :
					type = MouseEvent.CLICK;
					break;
			};
			var local:Point = target.globalToLocal(point);
			target.dispatchEvent(new MouseEvent(type , true , false , local.x , local.y));
		};
		
		
		/**
		 * check if object is accessable for mouse
		 * @param	target			target object
		 * @return					true if can be clicked , false if not
		 */
		public static function mouseEnabled(target:DisplayObject):Boolean {
			if (target is DisplayObject) {
				var loop:DisplayObjectContainer = target as DisplayObjectContainer;
			}else {
				loop = target.parent;
			};
			while (loop) {
				if (!loop.mouseChildren) {
					return false;
				};
				loop = loop.parent;
			};
			return true;
		};
		
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- UTILS
		
		/**
		 * return objects on stage under point
		 * @param	at			target position
		 * @return				array of points
		 */
		public static function getObjects(at:Point):Array {
			if (TouchManager.stage) {
				return TouchManager.stage.getObjectsUnderPoint(at);
			};
			return [];
		};
		
	};
};