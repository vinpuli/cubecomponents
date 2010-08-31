package cube.spark.utils {
	
	import cube.skins.spark.OrganizationChartItemSkin;
	import cube.spark.components.supportClasses.HierarchicalDataGroup;
	import cube.spark.components.supportClasses.OrganizationChartItem;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	import styleExplorerClasses.StyleExplorerEvent;
	
	[Event(name="styleChanged", type="flash.events.Event")]
	
	public final class OrganizationChartItemStyles extends EventDispatcher {
		
		private var _customStyles:Object = new Object();
		
		[Bindable("styleChanged")]
		public var cornerRadius:Number = 12;
		
		public function OrganizationChartItemStyles():void {
			//cornerRadius = target.getStyle("cornerRadius");
		}
		
		public function setStyle(propertyName:String, value:*):void {
			this[propertyName] = _customStyles[propertyName] = value;
			dispatchEvent(new StyleExplorerEvent(StyleExplorerEvent.STYLE_CHANGED, propertyName, value));
		}
		
		public function toCSS():String {
			var propertyName:String;
			var output:String = new String();
			output += "supportClasses|OrganizationChartItem";
			output += "\r{\r";
			for (propertyName in _customStyles) {
				output += "\t"+propertyName+": "+_customStyles[propertyName]+";\r";
			}
			output += "\r}";
			return output;
		}
	}
}