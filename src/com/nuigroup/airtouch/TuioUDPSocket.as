package com.nuigroup.airtouch 
{
	import com.nuigroup.touch.TouchCore;
	import flash.events.DatagramSocketDataEvent;
	import flash.net.DatagramSocket;
	
	/**
	 * ...
	 * @author Gerard Sławiński || turbosqel
	 */
	public class TuioUDPSocket extends DatagramSocket {
		
		public function TuioUDPSocket(target:int = 3333) {
			addEventListener(DatagramSocketDataEvent.DATA , onData);
			bind(target);
			receive();
		};
		
		private function onData(e:DatagramSocketDataEvent):void {
			TouchCore.parse(e.data);
		};
		
		public function remove():void {
			close();
			removeEventListener(DatagramSocketDataEvent.DATA , onData);
		};
		
	}

}