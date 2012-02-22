package com.nuigroup.touch.emulator {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Gerard Sławiński || turbosqel
	 */
	public class EventCheckBox extends Sprite {
		
		public var tf:TextField = new TextField();
		
		public function EventCheckBox() {
			graphics.beginFill(0x898545);
			graphics.drawRect(0, 0, 200, 200);
			graphics.endFill();
			
			alpha = 0.8
			addChild(tf);
			tf.x = 0;
			tf.y = 0;
			tf.width = 200;
			tf.height = 200;
			tf.multiline = true;
			mouseChildren = false;
			
			addEventListener(MouseEvent.CLICK , ms);
			addEventListener(MouseEvent.MOUSE_DOWN , ms);
			addEventListener(MouseEvent.MOUSE_UP , ms);
			addEventListener(MouseEvent.MOUSE_OVER , ms);
			addEventListener(MouseEvent.MOUSE_OUT , ms);
			addEventListener(MouseEvent.MOUSE_MOVE , ms);
			
			addEventListener(TouchEvent.TOUCH_BEGIN , ms);
			addEventListener(TouchEvent.TOUCH_OVER , ms);
			addEventListener(TouchEvent.TOUCH_OUT , ms);
			addEventListener(TouchEvent.TOUCH_END , ms);
			addEventListener(TouchEvent.TOUCH_MOVE , ms);
			addEventListener(TouchEvent.TOUCH_TAP , ms);
		};
		
		public function ms(e:Event):void {
			tf.appendText("\n" + e.type);
			tf.scrollV = tf.maxScrollV
		};
		
	};

};