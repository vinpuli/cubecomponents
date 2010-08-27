package styleExplorerClasses {
	
	import flash.events.Event;
	
	public final class StyleExplorerEvent extends Event {
		
		public static const STYLE_CHANGED:String = "styleChanged";
		
		private var _property:String;
		private var _value:*;
		
		public function StyleExplorerEvent(type:String, property:String, value:*, bubbles:Boolean=false, cancelable:Boolean=false):void {
			_property = property;
			_value = value;
			super(type, bubbles, cancelable);
		}
		
		public function get property():String {
			return _property;
		}
		
		public function get value():* {
			return _value;
		}
		
		override public function clone():Event {
			return new StyleExplorerEvent(type, _property, _value, bubbles, cancelable);
		}
	}
}