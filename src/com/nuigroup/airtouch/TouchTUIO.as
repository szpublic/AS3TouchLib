package com.nuigroup.airtouch {
	
	import com.nuigroup.touch.TouchCore;
	import com.nuigroup.touch.TouchManager;
	import com.nuigroup.touch.TouchProtocol;
	import flash.display.Stage;
	import flash.events.DatagramSocketDataEvent;
	import flash.net.DatagramSocket;
	
	/**
	 * ...
	 * @author Gerard Sławiński || turbosqel
	 */
	public class TouchTUIO {
		
		public static function listen(stage:Stage , port:int = 3333 , outputMode:String = "MouseEvent" ):void {
			TouchManager.stage = stage;
			TouchManager.inputMode = TouchProtocol.TUIO;
			TouchManager.outputMode = outputMode;
			new TuioUDPSocket(port);
		};
		
	}

}