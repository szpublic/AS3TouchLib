package {
	import com.nuigroup.touch.emulator.EventCheckBox;
	import com.nuigroup.touch.TouchManager;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Gerard Sławiński || turbosqel
	 */
	public class TouchTest extends Sprite {
		
		public function TouchTest():void {
			
			
			var spr:EventCheckBox = new EventCheckBox();
			spr.x = 400;
			spr.y = 300;
			addChild(spr);
			
			spr = new EventCheckBox();
			spr.x = 0;
			spr.y = 300;
			addChild(spr);
			
			spr = new EventCheckBox();
			spr.x = 400;
			spr.y = 0;
			addChild(spr);
			
			
			addChild(new EventCheckBox());
			
			TouchManager.initConnection(stage);
			
		};
		
		
	};
	
};