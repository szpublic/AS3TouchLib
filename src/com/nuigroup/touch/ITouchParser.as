package com.nuigroup.touch {
	import flash.utils.IDataInput;
	
	/**
	 * ...
	 * @author Gerard Sławiński || turbosqel
	 */
	public interface ITouchParser {
		
		function get name():String;
		
		function get header():String;
		
		function parse(data:IDataInput):void;
		
	}
	
}