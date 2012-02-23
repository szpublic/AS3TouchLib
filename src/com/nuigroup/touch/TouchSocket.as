package com.nuigroup.touch {
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.Endian;
	
	
	/**
	 * 
	 * @author Gerard Sławiński || turbosqel
	 */
	
	 
	 
	public class TouchSocket extends Socket {
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- INIT
		
		/**
		 * create new Socket and connect
		 * @param	host		host address
		 * @param	port		port number
		 */
		public function TouchSocket(host:String = "127.0.0.1", port:int = 3000):void {
			endian = Endian.LITTLE_ENDIAN;
			addEventListener(Event.CONNECT , socketConnected);
			addEventListener(Event.CLOSE , socketClosed);
			addEventListener(ProgressEvent.SOCKET_DATA , readData);
			addEventListener(IOErrorEvent.IO_ERROR , socketError);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR , socketError);
			connect(host , port);
		};
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- STATES HANDLERS
		
		/**
		 * on connect handler
		 * @param	e
		 */
		protected function socketConnected(e:Event):void {
			TouchManager.dispatchEvent(new TouchManagerEvent(TouchManagerEvent.CONNECTED));
		};
		
		/**
		 * socket close handler
		 */
		protected function socketClosed(e:Event):void {
			TouchManager.dispatchEvent(new TouchManagerEvent(TouchManagerEvent.CLOSED));
		};
		
		/**
		 * error handler , when security or ioerror dispatch
		 * @param	e
		 */
		protected function socketError(e:ErrorEvent):void {
			TouchManager.dispatchEvent(new TouchManagerEvent(TouchManagerEvent.ERROR , "[" + e.errorID + "]" + e.text ));
		};
		
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- DATA PARSER
		
		/**
		 * read data and push to TouchManager
		 * @param	e
		 */
		protected function readData(e:ProgressEvent):void {
			TouchCore.parse(this);
		};
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- UTILS
		
		/**
		 * remove listeners and close connection
		 */
		public function remove():void {
			removeEventListener(Event.CONNECT , socketConnected);
			removeEventListener(Event.CLOSE , socketClosed);
			removeEventListener(ProgressEvent.SOCKET_DATA , readData);
			removeEventListener(IOErrorEvent.IO_ERROR , socketError);
			removeEventListener(SecurityErrorEvent.SECURITY_ERROR , socketError);
			close();
		};
		
	}

}