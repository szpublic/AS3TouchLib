package com.nuigroup.touch {
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Gerard Sławiński || turbosqel
	 */
	public class Touch {
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- STATIC CONST
		
		/**
		 * delay for tap event , if time between touch start and end is smaller than TAP_DELAY , Tap events is dispatcher
		 */
		public static var TAP_DELAY:int = 220;
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- PARAMS
		
		/**
		 * touch id
		 */
		public var id:int;
		
		/**
		 * last touch position
		 */
		public var last:Point = new Point();
		
		/**
		 * actual touch position
		 */
		public var point:Point = new Point();
		
		/**
		 * acceleration or pressure
		 */
		public var force:Number;
		
		/**
		 * start time
		 */
		public var initTime:Number;
		
		/**
		 * actual elements on stage under touch point
		 */
		public var under:Array;
		
		/**
		 * recognized shape ID; for TUIO
		 */
		public var shape:Number = NaN;
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- INIT
		
		/**
		 * create new Touch data object
		 * @param	id				touch point id
		 * @param	x				x position
		 * @param	y				y position
		 * @param	initTime		initialize time
		 */
		public function Touch(id:int , x:Number , y:Number , initTime:Number) {
			this.id = id;
			point.x = x;
			point.y = y;
			this.initTime = initTime;
			
			under = TouchCore.getObjects(point);
			for each(var dsp:DisplayObject in under) {
				TouchCore.dispatchEvent(0, point,dsp, id);
			};
		};
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- FUNCTIONS
		
		/**
		 * apply move on touch and dispatch events
		 * @param	x		new x position
		 * @param	y		new y position
		 */
		public function move(x:Number , y:Number):void {
			// change new and last position
			last.x = point.x;
			last.y = point.y;
			point.x = x;
			point.y = y;
			// get points under new position
			var toDispatch:Array = TouchCore.getObjects(point);
			// loop through display objects
			for each(var dsp:DisplayObject in toDispatch) {
				// check if object was under point
				var index:int = under.indexOf(dsp);
				if (index == -1) {
					// wasnt , so dispatch OVER event
					TouchCore.dispatchEvent(1 ,point, dsp , id);
				} else {
					// was , so dispatch MOVE event
					TouchCore.dispatchEvent(2 , point,dsp, id);
					under[index] = null;
				};
			};
			
			for each (dsp in under) {
				if (dsp) {
					// rest of elements that we roll OUT
					TouchCore.dispatchEvent(3 ,point, dsp,id);
				};
			};
			// change elements list
			under.length = 0;
			under = toDispatch;
			
		};
		
		
		/**
		 * touch end , dispatch UP/END event and can dispatch TAP/CLICK
		 * @param	time		remove time
		 */
		public function end(time:Number):void {
			if (time - initTime < TAP_DELAY) {
				// dispatch UP/END and TAP/CLICK
				for each(var dsp:DisplayObject in under) {
					TouchCore.dispatchEvent(4,point,dsp,id);
					TouchCore.dispatchEvent(5,point,dsp,id);
				};
			}else {
				// dispatch only UP/END
				for each(dsp in under) {
					TouchCore.dispatchEvent(4,point,dsp,id);
				};
			};
			remove();
		};
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- REMOVE
		
		/**
		 * remove and release instances
		 */
		public function remove():void {
			if(under){
				under.length = 0;
				under = null;
			};
			point = null;
			last = null;
		};
		
	};

};