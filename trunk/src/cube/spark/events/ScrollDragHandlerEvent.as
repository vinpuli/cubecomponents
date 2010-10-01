package cube.spark.events {
	
	import flash.events.Event;
	
	public final class ScrollDragHandlerEvent extends Event {
		
		public static const SCROLL_DRAG:String = "scrollDrag";
		
		public function ScrollDragHandlerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false):void {
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new ScrollDragHandlerEvent(type, bubbles, cancelable);
		}
	}
}