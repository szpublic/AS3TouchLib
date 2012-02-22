package com.nuigroup.touch {
	import flash.events.Event;
	/**
	 * ...
	 * @author Gerard Sławiński || turbosqel
	 */
	public class TouchManagerEvent extends Event {
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- TYPES
		
		/**
		 * on socket connect
		 */
		public static const CONNECTED:String = "connected";
		/**
		 * on socket close
		 */
		public static const CLOSED:String = "closed";
		/**
		 * on socket error - IO or security
		 */
		public static const ERROR:String = "error";
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- INIT
		
		/**
		 * additional event informations
		 */
		public var info:String;
		
		/**
		 * create new CCVEvent to report class state
		 * @param	type		event type
		 * @param	info		additional informations
		 */
		public function TouchManagerEvent(type:String , info:String = null) {
			super(type);
			this.info = info;
			trace(this);
		};
		
		override public function toString():String {
			return "[ :CCVEvent: type:" + type + " , info:" + info + " ]";
		}
		
	}

}