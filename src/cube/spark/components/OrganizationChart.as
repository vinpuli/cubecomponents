package cube.spark.components {
	
	import cube.skins.spark.OrganizationChartSkin;
	import cube.spark.components.supportClasses.HierarchicalDataGroup;
	import cube.spark.events.OrganizationChartEvent;
	import cube.spark.layouts.supportClasses.LayoutUpdateType;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	import mx.styles.CSSSelector;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	import spark.components.Scroller;
	import spark.components.SkinnableContainer;
	
	[Event(name="dataGroupReady", type="cube.spark.events.OrganizationChartEvent")]
	
	[Style(name="dataGroupStyleName", type="String", inherit="no")]
	[Style(name="autoFocusItems", type="Boolean", inherit="no")]
	
	[ResourceBundle("components")]
	
	[DefaultProperty("dataProvider")]
	
	public class OrganizationChart extends SkinnableContainer {
		
		include "../core/Version.as";
		
		private const defaultStylesSet:Boolean = setupDefaultInheritingStyles();
		
		private var _dataProvider:IList;
		private var _doLaterSetDataProvider:Boolean = false;
		private var _invalidationTimeout:Boolean = false;
		
		[SkinPart(required="true")]
		public var dataGroup:HierarchicalDataGroup;
		
		[SkinPart(required="false")]
		public var scroller:Scroller;
		
		[Bindable]
		public function get dataProvider():IList {
			return _dataProvider;
		}
		
		public function set dataProvider(value:IList):void {
			if (value is ArrayCollection) {
				(value as ArrayCollection).source.sortOn("ownerId", Array.NUMERIC);
			}
			_dataProvider = value;
			if (dataGroup) {
				dataGroup.dataProvider = value;
			} else {
				_doLaterSetDataProvider = true;
			}
		}
		
		public function OrganizationChart():void {
			super();
		}
		
		public function focus(target:*):void {
			if (dataGroup) {
				dataGroup.focus(target);
			}
		}
		
		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			if (instance == dataGroup) {
				if (_doLaterSetDataProvider) {
					dataGroup.dataProvider = _dataProvider;
				}
				const dataGroupStyles:String = getStyle("dataGroupStyleName");
				if (dataGroupStyles) {
					const dataGroupStyleDeclaration:CSSStyleDeclaration = styleManager.getStyleDeclaration("."+dataGroupStyles);
					if (dataGroupStyleDeclaration) {
						dataGroup.styleManager.setStyleDeclaration("cube.spark.components.supportClasses.HierarchicalDataGroup", dataGroupStyleDeclaration, true);
					}
				}
				dataGroup.setStyle("autoFocusItems", getStyle("autoFocusItems"));
				dispatchEvent(new OrganizationChartEvent(OrganizationChartEvent.DATA_GROUP_READY, 0, null));
			} else if (instance == scroller) {
				scroller.horizontalScrollBar.addEventListener(Event.CHANGE, scroller_changeHandler, false, 0, true);
				scroller.verticalScrollBar.addEventListener(Event.CHANGE, scroller_changeHandler, false, 0, true);
			}
		}
		
		protected function setupDefaultInheritingStyles():Boolean {
			const styleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration(new CSSSelector("cube.spark.components.OrganizationChart"), styleManager);
			styleDeclaration.defaultFactory = function():void {
				this.skinClass = OrganizationChartSkin;
				this.backgroundColor = 0xffffff;
				this.backgroundAlpha = 1;
				this.borderColor = 0x000000;
				this.borderAlpha = 1;
				this.autoFocusItems = true;
			}
			return true;
		}
		
		private function scroller_changeHandler(event:Event):void {
			if (!_invalidationTimeout) {
				addEventListener(Event.ENTER_FRAME, self_enterFrameHandler, false, 0, true);
				_invalidationTimeout = true;
			}
		}

		private function self_enterFrameHandler(event:Event):void {
			removeEventListener(Event.ENTER_FRAME, self_enterFrameHandler);
			_invalidationTimeout = false;
			dataGroup.invalidateLayout(LayoutUpdateType.POSITIONAL);
		}
	}
}