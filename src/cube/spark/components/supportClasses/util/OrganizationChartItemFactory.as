package cube.spark.components.supportClasses.util {
	
	import cube.skins.spark.OrganizationChartItemSkin;
	import cube.spark.layouts.supportClasses.LayoutData;
	
	import org.as3commons.lang.Assert;
	
	public final class OrganizationChartItemFactory {
		
		private static var _nextId:int = 1;
		private static var _factoryDefaults:Object;
		
		public function OrganizationChartItemFactory():void {
		}
		
		public static function get factoryDefaults():Object {
			return _factoryDefaults;
		}
		
		public static function set factoryDefaults(value:Object):void {
			_factoryDefaults = value;
		}
		
		public static function reset():void {
			_nextId = 1;
		}
		
		public static function create(item:Object=null):LayoutData {
			const data:LayoutData = new LayoutData();
			var property:String;
			data.id = _nextId++;
			data.disconnected = false;
			data.state = 0;
			data.collapsed = false;
			data.hasChildren = true;
			if (_factoryDefaults) {
				for (property in _factoryDefaults) {
					data[property] = _factoryDefaults[property];
				}
			}
			if (item) {
				for (property in item) {
					data[property] = item[property];
				}
			}
			data.itemRendererSkin = OrganizationChartItemSkin;
			return data;
		}
	}
}