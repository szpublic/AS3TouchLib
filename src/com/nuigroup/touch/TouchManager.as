package com.nuigroup.touch {
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.Endian;
	/**
	 * 
	 * @author Gerard Sławiński || turbosqel
	 */
	public class TouchManager {
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- SETTINGS
		
		/**
		 * build in parsers
		 */
		internal static var parsers:Object = {autoChoose:TouchCore.parseCheck , ccvbinary:TouchCore.parseCCV , flashtouchevent:TouchCore.parseFlashEvent };
		/**
		 * build in parsers headers
		 */
		internal static var headers:Object = { CCV:TouchProtocol.CCVINPUT , FL:TouchProtocol.FLASHEVENT };
		
		/**
		 * 
		 * @param	name
		 * @param	header
		 * @param	parsingFunction
		 */
		public static function addParser(name:String , header:String , parsingFunction:Function):void {
			parsers[name] = parsingFunction;
			headers[header] = name;
		};
		
		/**
		 * input mode name
		 * function 
		 */
		internal static var input:String;
		/**
		 * output mode name
		 * MouseEvent or TouchEvent
		 */
		internal static var output:String;
		
		/**
		 * set binary data reader type . Default is automatic check .
		 */
		public static function set inputMode(mode:String):void {
			TouchCore.parser = parsers[mode];
			input = mode;
			if (TouchCore.parser == null) {
				TouchCore.parser = TouchCore.parseCheck;
				input = TouchProtocol.AUTO;
			};
		};
		
		/**
		 * return input mode type
		 */
		public static function get inputMode():String {
			return input;
		};
		
		/**
		 * output events , MouseEvent or TouchEvent . Use static instances of TouchOutput class .
		 */
		public static function set outputMode(mode:String):void {
			switch(mode) {
				case TouchOutput.TOUCH :
					TouchCore.EventDelegate = TouchCore.dispatchTouchEvent;
					output = mode;
					return;
				default :
					TouchCore.EventDelegate = TouchCore.dispatchMouseEvent;
					output = TouchOutput.MOUSE;
			};
		};
		
		/**
		 * output events type , MouseEvent or TouchEvent
		 */
		public static function get outputMode():String {
			return output
		};
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- GLOBAL INITIALIZER
		
		/**
		 * create new socket connection and listener for data
		 * @param	stage				stage instance , place to dispatch events
		 * @param	host				host address
		 * @param	port				port number
		 * @param	inputMode			bytes reading mode - use TouchProtocol class
		 * @param	outputMode			type of dispatching events - use TouchOutput class
		 */
		public static function initConnection(stage:Stage , host:String = "127.0.0.1" , port:int = 3000 , inputMode:String = "autoChoose" ,outputMode:String = "MouseEvent"):void {
			TouchManager.stage = stage;
			input = inputMode;
			output = outputMode;
			connect(host , port);
		};
		
		/**
		 * 
		 * @param	stage				stage instance , place to dispatch events
		 * @param	socket				target socket to listen
		 * @param	inputMode			bytes reading mode - use TouchProtocol class
		 * @param	outputMode			type of dispatching events - use TouchOutput class
		 */
		public static function initSocket(stage:Stage , socket:Socket , inputMode:String = "autoChoose" , outputMode:String = "MouseEvent"):void {
			TouchManager.stage = stage;
			input = inputMode;
			output = outputMode;
			socket.addEventListener(ProgressEvent.SOCKET_DATA , TouchCore.reciveData);
		};
		
		
		public static function addSocket(s:Socket):void {
			s.endian = Endian.LITTLE_ENDIAN;
			s.addEventListener(ProgressEvent.SOCKET_DATA , TouchCore.reciveData);
		};
		
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- STATIC EVENT DISPATCHER
		
		protected static var ed:EventDispatcher = new EventDispatcher();
		public static function addEventListener(type:String , listener:Function):void {
			ed.addEventListener(type, listener);
		};
		public static function removeEventListener(type:String , listener:Function):void {
			ed.removeEventListener(type, listener);
		};
		internal static function dispatchEvent(event:Event):Boolean {
			return ed.dispatchEvent(event);
		};
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- STAGE ACCESS
		
		/**
		 * stage instance
		 */
		protected static var _stage:Stage;
		
		/**
		 * return stage instance
		 */
		static public function get stage():Stage {
			return _stage;
		};
		/**
		 * set stage instance
		 */
		static public function set stage(value:Stage):void {
			_stage = value;
		};
		
		/**
		 * return stage width
		 */
		static internal function get width():Number {
			return stage ? stage.stageWidth : 0;
		};
		
		/**
		 * return stage height
		 */
		static internal function get height():Number {
			return stage ? stage.stageHeight : 0;
		};
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- SOCKET INITIALIZATION / HANDLING
		
		/**
		 * created socket
		 */
		protected static var socket:TouchSocket;
		
		/**
		 * create TCP connection
		 * @param	address		host ip address
		 * @param	port		host port number
		 */
		public static function connect(address:String = "127.0.0.1" , port:int = 3000):void {
			if (socket) {
				socket.remove();
			};
			socket = new TouchSocket(address , port);
		};
		
		
		
		
		
	};
};