package cube.spark.utils {
	
	import cube.skins.spark.OrganizationChartItemSkin;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	[Event(name="styleChanged", type="flash.events.Event")]
	
	public final class HierarchicalDataGroupStyles extends EventDispatcher {
		
		private var _customStyles:Object = new Object();
		
		[Bindable("styleChanged")]
		public var itemRendererSkin:Class = OrganizationChartItemSkin;
		[Bindable("styleChanged")]
		public var horizontalPadding:Number = 60;
		[Bindable("styleChanged")]
		public var verticalPadding:Number = 60;
		[Bindable("styleChanged")]
		public var itemMinimizedWidth:Number = 30;
		[Bindable("styleChanged")]
		public var itemMinimizedHeight:Number = 80;
		[Bindable("styleChanged")]
		public var itemNormalWidth:Number = 60;
		[Bindable("styleChanged")]
		public var itemNormalHeight:Number = 100;
		[Bindable("styleChanged")]
		public var itemMaximizedWidth:Number = 160;
		[Bindable("styleChanged")]
		public var itemMaximizedHeight:Number = 120;
		
		public function setStyle(propertyName:String, value:*):void {
			this[propertyName] = _customStyles[propertyName] = value;
			dispatchEvent(new Event("styleChanged"));
		}
		
		public function toCSS():String {
			var propertyName:String;
			var output:String = new String();
			output += ".dataGroup";
			output += "\r{\r";
			for (propertyName in _customStyles) {
				if (propertyName == "itemRendererSkin") {
					const className:String = getQualifiedClassName(_customStyles[propertyName]);
					output += "\t"+propertyName+": "+className.split("::")[1]+";\r";
				} else {
					output += "\t"+propertyName+": "+_customStyles[propertyName]+";\r";
				}
			}
			output += "}";
			return output;
		}
	}
}