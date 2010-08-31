package cube.spark.utils {
	
	import cube.spark.components.OrganizationChart;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	import styleExplorerClasses.StyleExplorerEvent;
	
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
		[Bindable("styleChanged")]
		public var autoFocusItems:Boolean = true;
		[Bindable("styleChanged")]
		public var connectorLineColor:uint = 0xcccccc;
		[Bindable("styleChanged")]
		public var connectorLineAlpha:Number = 1;
		[Bindable("styleChanged")]
		public var connectorLineThickness:Number = 2;
		
		public function OrganizationChartStyles(target:OrganizationChart):void {
			backgroundColor = target.getStyle("backgroundColor");
			backgroundAlpha = target.getStyle("backgroundAlpha");
			borderColor = target.getStyle("borderColor");
			borderAlpha = target.getStyle("borderAlpha");
			dataGroupStyleName = target.getStyle("dataGroupStyleName");
			autoFocusItems = target.getStyle("autoFocusItems");
			connectorLineColor = target.getStyle("connectorLineColor");
			connectorLineAlpha = target.getStyle("connectorLineAlpha");
			connectorLineThickness = target.getStyle("connectorLineThickness");
		}
		
		public function setStyle(propertyName:String, value:*):void {
			this[propertyName] = _customStyles[propertyName] = value;
			dispatchEvent(new StyleExplorerEvent(StyleExplorerEvent.STYLE_CHANGED, propertyName, value));
		}
		
		public function toCSS():String {
			var propertyName:String;
			var output:String = new String();
			output += "components|OrganizationChart";
			output += "\r{\r";
			for (propertyName in _customStyles) {
				if (propertyName == "backgroundColor" ||
					propertyName == "borderColor" ||
					propertyName == "connectorLineColor"
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