package cube.spark.events {
	
	import flash.events.Event;
	
	public final class ConnectorEvent extends Event {
		
		public static const CONNECTOR_LAYOUT_CHANGE:String = "connectorLayoutChange";
		
		public function ConnectorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false):void {
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new ConnectorEvent(type, bubbles, cancelable);
		}
	}
}