package cube.spark.components {
	
	import cube.skins.spark.OrganizationChartSkin;
	import cube.spark.components.supportClasses.HierarchicalDataGroup;
	import cube.spark.components.supportClasses.ScrollDragHandler;
	import cube.spark.effects.PixelBenderEffect;
	import cube.spark.events.OrganizationChartEvent;
	import cube.spark.events.ScrollDragHandlerEvent;
	import cube.spark.layouts.supportClasses.LayoutUpdateType;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.events.EffectEvent;
	import mx.styles.CSSSelector;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.Scroller;
	import spark.components.SkinnableContainer;
	
	[Event(name="dataGroupReady", type="cube.spark.events.OrganizationChartEvent")]
	
	[Style(name="borderAlpha", type="Number", inherit="no")]
	[Style(name="borderColor", type="Number", inherit="no")]
	[Style(name="dataGroupStyleName", type="String", inherit="no")]
	[Style(name="autoFocusItems", type="Boolean", inherit="no")]
	[Style(name="connectorLineColor", type="uint", format="Color", inherit="no")]
	[Style(name="connectorLineAlpha", type="Number", inherit="no")]
	[Style(name="connectorLineThickness", type="Number", inherit="no")]
	
	[ResourceBundle("components")]
	
	[DefaultProperty("dataProvider")]
	
	public class OrganizationChart extends SkinnableContainer {
		
		include "../core/Version.as";
		
		private const defaultStylesSet:Boolean = setupDefaultInheritingStyles();
		
		private var _dataProvider:IList;
		private var _doLaterSetDataProvider:Boolean = false;
		private var _invalidationTimeout:Boolean = false;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _zoomEffect:PixelBenderEffect;
		
		[SkinPart(required="true")]
		public var dataGroup:HierarchicalDataGroup;
		
		[SkinPart(required="false")]
		public var scroller:Scroller;
		
		[SkinPart(required="false")]
		public var scrollDragHandler:ScrollDragHandler;
		
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
		
		override public function get scaleX():Number {
			return _scaleX;
		}
		
		override public function set scaleX(value:Number):void {
			_scaleX = value;
			if (dataGroup) {
				dataGroup.scaleX = value;
			}
		}
		
		override public function get scaleY():Number {
			return _scaleY;
		}
		
		override public function set scaleY(value:Number):void {
			_scaleY = value;
			if (dataGroup) {
				dataGroup.scaleY = value;
			}
		}
		
		public function zoom():void {
			return;
			/*if (_zoomEffect && (width*height <= 640*480)) {
				_zoomEffect.addEventListener(EffectEvent.EFFECT_UPDATE, zoomEffect_effectUpdateHandler, false, 0, true);
				_zoomEffect.addEventListener(EffectEvent.EFFECT_END, zoomEffect_effectEndHandler, false, 0, true);
				_zoomEffect.start(
					{
						center: [dataGroup.width*.5, dataGroup.height*.5],
						amount: .5
					},
					{
						center: [dataGroup.width*.5, dataGroup.height*.5],
						amount: 0
					},
					200
				);
			}*/
		}
		
		public function focus(target:*):void {
			if (dataGroup) {
				dataGroup.focus(target);
			}
		}
		
		override public function setStyle(styleProp:String, newValue:*):void {
			switch (styleProp) {
				case "autoFocusItems" : case "connectorLineColor" : case "connectorLineAlpha" : case "connectorLineThickness" :
					if (dataGroup) {
						dataGroup.setStyle(styleProp, newValue);
					}
					break;
			}
			super.setStyle(styleProp, newValue);
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
				dataGroup.setStyle("connectorLineColor", getStyle("connectorLineColor"));
				dataGroup.scaleX = _scaleX;
				dataGroup.scaleY = _scaleY;
				//_zoomEffect = new PixelBenderEffect();
				//_zoomEffect.target = dataGroup;
				//_zoomEffect.shader = new (getStyle("zoomFilter"))();
				dispatchEvent(new OrganizationChartEvent(OrganizationChartEvent.DATA_GROUP_READY, 0, null));
			} else if (instance == scroller) {
				scroller.horizontalScrollBar.addEventListener(Event.CHANGE, scroller_changeHandler, false, 0, true);
				scroller.verticalScrollBar.addEventListener(Event.CHANGE, scroller_changeHandler, false, 0, true);
			} else if (instance == scrollDragHandler) {
				scrollDragHandler.addEventListener(ScrollDragHandlerEvent.SCROLL_DRAG, scrollDragHandler_scrollDragHandler, false, 0, true);
			}
		}
		
		protected function setupDefaultInheritingStyles():Boolean {
			//if (!styleManager.getStyleDeclaration("cube.spark.components.OrganizationChart")) {
				const styleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration(new CSSSelector("cube.spark.components.OrganizationChart"), styleManager);
				styleDeclaration.defaultFactory = function():void {
					this.skinClass = OrganizationChartSkin;
					this.backgroundColor = 0xffffff;
					this.backgroundAlpha = 1;
					this.borderColor = 0x000000;
					this.borderAlpha = 1;
					this.autoFocusItems = true;
					this.connectorLineColor = 0xcccccc;
					this.connectorLineAlpha = 1;
					this.connectorLineThickness = 2;
				}
				//styleManager.setStyleDeclaration("cube.spark.components.OrganizationChart", styleDeclaration, true);
			//}
			return true;
		}
		
		protected function handleScrollUpdate():void {
			if (!_invalidationTimeout) {
				addEventListener(Event.ENTER_FRAME, self_enterFrameHandler, false, 0, true);
				_invalidationTimeout = true;
			}
		}
		
		private function scroller_changeHandler(event:Event):void {
			handleScrollUpdate();
		}
		
		private function scrollDragHandler_scrollDragHandler(event:ScrollDragHandlerEvent):void {
			handleScrollUpdate();
		}
		
		private function zoomEffect_effectUpdateHandler(event:EffectEvent):void {
			scaleX -= .02;
			scaleY -= .02;
		}
		
		/*private function zoomEffect_effectEndHandler(event:EffectEvent):void {
			_zoomEffect.removeEventListener(EffectEvent.EFFECT_UPDATE, zoomEffect_effectUpdateHandler);
			_zoomEffect.removeEventListener(EffectEvent.EFFECT_END, zoomEffect_effectEndHandler);
		}*/

		private function self_enterFrameHandler(event:Event):void {
			removeEventListener(Event.ENTER_FRAME, self_enterFrameHandler);
			_invalidationTimeout = false;
			dataGroup.invalidateLayout(LayoutUpdateType.POSITIONAL);
		}
	}
}