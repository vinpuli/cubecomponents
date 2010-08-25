package cube.spark.components.supportClasses {
	
	import cube.spark.events.ConnectorEvent;
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	import mx.events.PropertyChangeEvent;
	
	import spark.core.IViewport;
	import spark.skins.SparkSkin;
	
	[Event(name="connectorLayoutChange", type="cube.spark.events.ConnectorEvent")]
	
	public class HierarchicalConnector extends EventDispatcher {
		
		include "../../core/Version.as";
		
		private var _viewport:IViewport;
		private var _x:Number;
		private var _percentX:Number;
		private var _y:Number;
		private var _percentY:Number;
		private var _orientation:String;
		
		public function HierarchicalConnector():void {
			
		}
		
		[Bindable("connectorLayoutChange")]
		[Inspectable(category="General", enumeration="bottom,left,right,top")]
		public function get orientation():String {
			return _orientation;
		}
		
		public function set orientation(value:String):void {
			_orientation = value;
		}
		
		[Bindable("connectorLayoutChange")]
		[Inspectable(category="General")]
		[PercentProxy("percentX")]
		public function get viewport():IViewport {
			return _viewport;
		}
		
		public function set viewport(value:IViewport):void {
			_viewport = value;
			value.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler, false, 0, true);
		}
		
		[Bindable("connectorLayoutChange")]
		[Inspectable(category="General")]
		[PercentProxy("percentX")]
		public function get x():Number {
			return _x;
		}
		
		public function set x(value:Number):void {
			_x = value;
		}
		
		[Bindable("connectorLayoutChange")]
		[Inspectable(environment="none")]
		public function get percentX():Number {
			return _percentX;
		}
		
		public function set percentX(value:Number):void {
			_percentX = value;
		}
		
		[Bindable("connectorLayoutChange")]
		[Inspectable(category="General")]
		[PercentProxy("percentY")]
		public function get y():Number {
			return _y;
		}
		
		public function set y(value:Number):void {
			_y = value;
		}
		
		[Bindable("connectorLayoutChange")]
		[Inspectable(environment="none")]
		public function get percentY():Number {
			return _percentY;
		}
		
		public function set percentY(value:Number):void {
			_percentY = value;
		}
		
		private function viewport_propertyChangeHandler(event:PropertyChangeEvent):void {
			const hasPercentX:Boolean = !isNaN(_percentX);
			const hasPercentY:Boolean = !isNaN(_percentY);
			if (hasPercentX || hasPercentY) {
				switch (event.property) {
					case "contentWidth" :
						if (hasPercentX) {
							_x = _percentX*_viewport.contentWidth/100;
						}
						break;
					case "contentHeight" :
						if (hasPercentY) {
							_y = _percentY*_viewport.contentHeight/100;
						}
						break;
				}
			}
			if (hasEventListener(ConnectorEvent.CONNECTOR_LAYOUT_CHANGE)) {
				dispatchEvent(new ConnectorEvent(ConnectorEvent.CONNECTOR_LAYOUT_CHANGE));
			}
		}
		
	}
}