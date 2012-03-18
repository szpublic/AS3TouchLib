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
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	import flash.utils.setTimeout;
	
	/**
	 * 
	 * 
	 * 
	 * 
	 * @version 1
	 * 
	 * @author Gerard Sławiński || nuigroup.turbosqel
	 */
	public class TouchCore {
		
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- PARSING
		
		/**
		 * clear touch interval , when delay between sending data is too long
		 */
		protected static var interval:Number;
		
		/**
		 * ccv timeout delay
		 */
		public static var CCVTimeout:int = 300;
		
		/**
		 * object contain touch's data
		 */
		public static var touchData:Object = new Object();
		
		/**
		 * object contain recognized touchs ( for TUIO )
		 */
		public static var objectsData:Object = new Object();
		
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
		internal static var parser:Function = parseCheck;
		
		/**
		 * recive data from socket and parse
		 * @param	e
		 */
		internal static function reciveData(e:ProgressEvent):void {
			parse(e.target as Socket);
		};
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<---------------- AUTO CHECK&CHOOSE PARSER
		
		/**
		 * function that read header , check for data type and switch to correct encoding function
		 * @param	data		IDataInput element
		 */
		public static function parseCheck(data:IDataInput):void {
			var read:ByteArray = new ByteArray();
			data.readBytes(read);
			read.endian = Endian.LITTLE_ENDIAN;
			data.endian = Endian.LITTLE_ENDIAN;
			
			for (var head:String in TouchManager.headers) {
				read.position = 0;
				if (head.length <= read.length &&head == read.readUTFBytes(head.length)) {
					TouchManager.inputMode = TouchManager.headers[head];
					break;
				};
			};
			
			if (parser == arguments.callee) {
				trace("unknown header");
				return;
			};
			
			read.position = 0;
			parser(read);
			
		};
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<---------------- CCV PARSER
		
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
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<---------------- FLASH XML PARSER
		
		public static function parseXML(data:IDataInput):void {
			try {
				var recived:Object = new Object();
				var time:Number = (new Date).getTime();
				var newStack:Object = new Object();
				
				var xml:XML = XML(data.readUTFBytes(data.bytesAvailable));
				var msg:XMLList = xml.children();
				for each(var info:XML in msg) {
					var params:XMLList = info.children();
					if (params.length() == 7) {
						var id:int = int(params[1].@VALUE);
						var touch:Touch = touchData[id];
						if (touch) {
							touch.move(Number(params[2].@VALUE) * TouchManager.width , Number(params[3].@VALUE) * TouchManager.height );
							touchData[id] = null;
						}else {
							touch = new Touch( id , Number(params[2].@VALUE) * TouchManager.width , Number(params[3].@VALUE) * TouchManager.height  , time );
						};
						newStack[id] = touch;
						touch.force = Number(params[6].@VALUE);
					};
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
			if(!isNaN(interval)){
				clearInterval(interval);
			};
			interval = setTimeout(clearTouch, CCVTimeout);
		};
		
		////////////////////////////////////////////////////
		
		//<---------------- TOUCH DATA REMOVE , FOR CCV AND XML
		
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
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<---------------- FLASH EVENTS PARSER
		
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
		
		//<------------------------- TUIO
		
		public static var sequence:uint;
		
		/**
		 * parse tuio message
		 * @param	raw
		 */
		public static function parseTUIO(raw:IDataInput):void {
			if (raw.bytesAvailable == 44 || raw.bytesAvailable == 48) {
				return;
			}
			trace("parseTUIO");
			var bytes:ByteArray = new ByteArray();
			raw.readBytes(bytes);
			try {
				if ("#bundle" == bytes.readUTFBytes(8)) {
					bytes.readUnsignedInt();// time
					bytes.readUnsignedInt();// time
					var length:int = bytes.readInt();
					trace("length:",length);
					var message:String = getMSG(bytes);
					trace(message);
					var params:Array = readParams(getMSG(bytes) , bytes);
					params.shift();// remove type string
					var alive:Array = params;// alive touch's
					trace("alive:",alive);
					bytes.position += 4; //
				} else {
					trace("header error");
					return;
				};
				// get frame time
				var time:Number = (new Date).getTime();
				// loop on informations
				while (bytes.bytesAvailable) {
					if (bytes.readUTFBytes(1) == "/") {
						bytes.position --;
						var type:String = getMSG(bytes);
						message = getMSG(bytes);
						params = readParams(message , bytes);
						trace(type , message);
						switch(params[0]) {
							case "set":
								switch(type) {
									case "tuio/2Dobj" :
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
								
								break;
								
							case "fseq":
								//trace("sequence:", params[1]);
								sequence = params[1];
								break;
						}
						//bytes.position +=4;
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
		
		protected static function getMSG(bytes:IDataInput):String {
			var out:String = "";
			while (bytes.bytesAvailable > 0) {
				var char:String = bytes.readUTFBytes(4);
				out += char;
				if(char.length < 4) break;
			};
			return out;
		}
		
		
		
		
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
		internal static var EventDelegate:Function = dispatchMouseEvent;
		
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