package cube.spark.events {
	
	import cube.spark.components.supportClasses.IOrganizationChartItemRenderer;
	
	import flash.events.Event;
	
	public final class OrganizationChartEvent extends Event {
		
		public static const ITEM_MINIMIZE_STATE:String = "itemMinimizeState";
		public static const ITEM_NORMAL_STATE:String = "itemNormalState";
		public static const ITEM_MAXIMIZE_STATE:String = "itemMaximizeState";
		public static const DATA_GROUP_READY:String = "dataGroupReady";
		public static const UPDATE_COMPLETE:String = "updateComplete";
		public static const COLLAPSED_CHANGE:String = "collapsedChange";
		public static const DISCONNECTED_CHANGE:String = "disconnectedChange";
		public static const RENDERER_SKIN_READY:String = "rendererSkinReady";
		
		private var _listIndex:int;
		private var _itemRenderer:IOrganizationChartItemRenderer;
		
		public function OrganizationChartEvent(type:String, listIndex:int, itemRenderer:IOrganizationChartItemRenderer, bubbles:Boolean=false, cancelable:Boolean=false):void {
			_listIndex = listIndex;
			_itemRenderer = itemRenderer;
			super(type, bubbles, cancelable);
		}
		
		public function get listIndex():int {
			return _listIndex;
		}
		
		public function get itemRenderer():IOrganizationChartItemRenderer {
			return _itemRenderer;
		}
		
		override public function clone():Event {
			return new OrganizationChartEvent(type, _listIndex, _itemRenderer, bubbles, cancelable);
		}
	}
}