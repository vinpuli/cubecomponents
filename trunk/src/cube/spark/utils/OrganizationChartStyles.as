package cube.spark.utils {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Event(name="styleChanged", type="flash.events.Event")]
	
	public final class OrganizationChartStyles extends EventDispatcher {
		
		private var _customStyles:Object = new Object();
		
		[Bindable("styleChanged")]
		public var backgroundColor:uint = 0xffffff;
		[Bindable("styleChanged")]
		public var backgroundAlpha:Number = 1;
		[Bindable("styleChanged")]
		public var borderColor:uint = 0x000000;
		[Bindable("styleChanged")]
		public var borderAlpha:Number = 1;
		[Bindable("styleChanged")]
		public var dataGroupStyleName:String;
		
		public function setStyle(propertyName:String, value:*):void {
			this[propertyName] = _customStyles[propertyName] = value;
			dispatchEvent(new Event("styleChanged"));
		}
		
		public function toCSS():String {
			var propertyName:String;
			var output:String = new String();
			output += "components|OrganizationChart";
			output += "\r{\r";
			for (propertyName in _customStyles) {
				if (propertyName == "backgroundColor" ||
					propertyName == "borderColor"
				) {
					output += "\t"+propertyName+": #"+(_customStyles[propertyName] as uint).toString(16)+";\r";
				} else {
					output += "\t"+propertyName+": "+_customStyles[propertyName]+";\r";
				}
			}
			output += "\tdataGroupStyleName: dataGroup;";
			output += "\r}";
			return output;
		}
	}
}