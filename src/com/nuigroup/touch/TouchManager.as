package com.nuigroup.touch {
	import com.nuigroup.touch.parsers.AutoCheck;
	import com.nuigroup.touch.parsers.CCVBinary;
	import com.nuigroup.touch.parsers.FlashEvents;
	import com.nuigroup.touch.parsers.FlashXML;
	import com.nuigroup.touch.parsers.TUIOEncode;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.Endian;
	/**
	 * 
	 * Main class for manage TouchLib .
	 * Here You can set input (binary data parser ; check TouchProtocol class)
	 * and touch output ( dispatching events - MouseEvent , TouchEvent , or own handler ; check TouchOutput and github info's )
	 * 
	 * 
	 * 
	 * 
	 * @usage	For quick run use initConnection and initSocket functions . More detiles You can find in github README or NUIGroup forums
	 * @link	nuigroup.com/forums
	 * @author	Gerard Sławiński || turbosqel.pl
	 */
	public class TouchManager {
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- SETTINGS & DATA
		
		/**
		 * build-in parsers
		 */
		protected static var _parsers:Object;
		
		protected static const auto:AutoCheck = new AutoCheck();
		
		/**
		 * return parsers
		 */
		public static function get parsers():Object {
			if (!_parsers) {
				_parsers = new Object();
				// ccv :
				_parsers[TouchProtocol.CCVINPUT] = new CCVBinary();
				// flash events
				_parsers[TouchProtocol.FLASHEVENT] = new FlashEvents();
				// xml
				_parsers[TouchProtocol.FLASHXML] = new FlashXML();
				// tuio
				_parsers[TouchProtocol.TUIO] = new TUIOEncode();
			};
			return _parsers;
		};
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- ADD PARSER
		
		/**
		 * add new parser to index
		 * @param	name				parser name
		 * @param	header				string to compare with header of message (for autoChoose function)
		 * @param	parsingFunction		function that recive message binary data , ex: function (data:IDataInput):void ;
		 * @param	focus				if true , this parser will be set as primary
		 */
		public static function addParser( parser:ITouchParser , focus:Boolean = false):void {
			parsers[parser.name] = parser;
			if(focus){
				TouchCore.parser = parser;
			};
		};
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- INPUT & OUTPUT SETTINGS
		
		/**
		 * output mode name
		 * MouseEvent or TouchEvent
		 */
		internal static var output:String;
		
		/**
		 * set binary data reader type , for build-in parsers use TouchProtocol class const values . Default is auto-check .
		 */
		public static function set inputMode(name:String):void {
			TouchCore.parser = parsers[name];
			if (TouchCore.parser == null) {
				TouchCore.parser = auto;
			};
		};
		
		/**
		 * return input mode type
		 */
		public static function get inputMode():String {
			return TouchCore.parser.name;
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
		 * @param	inputMode			bytes reading mode (CCV , TouchEvents) - use TouchProtocol class
		 * @param	outputMode			type of dispatching events (MouseEvent or TouchEvent)- use TouchOutput class
		 */
		public static function initConnection(stage:Stage , host:String = "127.0.0.1" , port:int = 3000 , input:String = "autoChoose" ,output:String = "MouseEvent"):void {
			TouchManager.stage = stage;
			inputMode = input;
			outputMode = output;
			connect(host , port);
		};
		
		/**
		 * 
		 * @param	stage				stage instance , place to dispatch events
		 * @param	socket				target socket to listen
		 * @param	inputMode			bytes reading mode - use TouchProtocol class
		 * @param	outputMode			type of dispatching events - use TouchOutput class
		 */
		public static function initSocket(stage:Stage , socket:Socket , input:String = "autoChoose" , output:String = "MouseEvent"):void {
			TouchManager.stage = stage;
			inputMode = input;
			outputMode = output;
			socket.addEventListener(ProgressEvent.SOCKET_DATA , TouchCore.reciveData);
		};
		
		/**
		 * focus on socket
		 * @param	s		target tcp socket
		 */
		public static function addSocket(s:Socket):void {
			s.endian = Endian.LITTLE_ENDIAN;
			s.addEventListener(ProgressEvent.SOCKET_DATA , TouchCore.reciveData);
		};
		
		
		////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////
		
		//<------------------------- STATIC EVENT DISPATCHER
		
		protected static var ed:EventDispatcher = new EventDispatcher();
		
		/**
		 * adds event listener
		 * @param	type		event type
		 * @param	listener	callback function
		 */
		public static function addEventListener(type:String , listener:Function):void {
			ed.addEventListener(type, listener);
		};
		
		/**
		 * remove event listener
		 * @param	type		event type
		 * @param	listener	callback function
		 */
		public static function removeEventListener(type:String , listener:Function):void {
			ed.removeEventListener(type, listener);
		};
		
		/**
		 * dispatch event
		 * @param	event
		 * @return
		 */
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
		static public function get width():Number {
			return stage ? stage.stageWidth : 0;
		};
		
		/**
		 * return stage height
		 */
		static public function get height():Number {
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