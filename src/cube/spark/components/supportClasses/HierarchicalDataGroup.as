package cube.spark.components.supportClasses {
	
	import cube.skins.spark.OrganizationChartItemSkin;
	import cube.spark.events.OrganizationChartEvent;
	import cube.spark.layouts.HierarchicalLayout;
	import cube.spark.layouts.supportClasses.LayoutData;
	import cube.spark.layouts.supportClasses.LayoutUpdateType;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.controls.ComboBase;
	import mx.controls.dataGridClasses.DataGridItemRenderer;
	import mx.core.ClassFactory;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.effects.IEffectInstance;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.events.ListEventReason;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.events.ResizeEvent;
	import mx.managers.IFocusManagerComponent;
	import mx.styles.CSSSelector;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.ComboBox;
	import spark.components.DataGroup;
	import spark.components.IItemRendererOwner;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.effects.Resize;
	import spark.effects.easing.Bounce;
	import spark.effects.easing.Elastic;
	import spark.effects.supportClasses.ResizeInstance;
	import spark.events.RendererExistenceEvent;
	import spark.skins.spark.DefaultComplexItemRenderer;
	import spark.skins.spark.DefaultItemRenderer;
	
	use namespace mx_internal;
	
	[Event(name="itemMinimizeState", type="cube.spark.events.OrganizationChartEvent")]
	[Event(name="itemNormalState", type="cube.spark.events.OrganizationChartEvent")]
	[Event(name="itemMaximizeState", type="cube.spark.events.OrganizationChartEvent")]
	
	[Style(name="itemMinimizedWidth", type="Number", format="Length", inherit="yes")]
	[Style(name="itemMinimizedHeight", type="Number", format="Length", inherit="yes")]
	[Style(name="itemNormalWidth", type="Number", format="Length", inherit="yes")]
	[Style(name="itemNormalHeight", type="Number", format="Length", inherit="yes")]
	[Style(name="itemMaximizedWidth", type="Number", format="Length", inherit="yes")]
	[Style(name="itemMaximizedHeight", type="Number", format="Length", inherit="yes")]
	[Style(name="horizontalPadding", type="Number", format="Length", inherit="yes")]
	[Style(name="verticalPadding", type="Number", format="Length", inherit="yes")]
	
	[ResourceBundle("components")]
	
	[DefaultProperty("dataProvider")]
	
	public class HierarchicalDataGroup extends DataGroup {
		
		include "../../core/Version.as";
		
		private const defaultStylesSet:Boolean = setupDefaultInheritingStyles();
		
		private var _connectorCanvas:UIComponent;
		private var _hierarchicalLayout:HierarchicalLayout;
		private var _doLaterSetHierarchicalLayout:Boolean = false;
		private var _visibleItemsData:Vector.<LayoutData>;
		private var _dataProvider:IList;
		private var _dataProviderChanged:Boolean = false;
		private var _itemRendererField:String = "itemRenderer";
		private var _itemRendererFunction:Function;
		private var _itemRendererFieldOrFunctionChanged:Boolean = true;
		private var _itemRenderers:Vector.<IOrganizationChartItemRenderer>;
		private var _animationFlag:Boolean = false;
		
		public function HierarchicalDataGroup():void {
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete, false, 0, true);
			itemRenderer = new ClassFactory(OrganizationChartItem);
		}
		
		override public function get contentWidth():Number {
			if (_hierarchicalLayout) {
				return _hierarchicalLayout.measuredWidth;
			}
			return super.contentWidth;
		}
		
		override public function get contentHeight():Number {
			if (_hierarchicalLayout) {
				return _hierarchicalLayout.measuredHeight;
			}
			return super.contentHeight;
		}
		
		override public function set dataProvider(value:IList):void {
			_dataProvider = value;
			if (initialized) {
				injectDefaultProperties(_dataProvider);
				_dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler, false, 0, true);
				_hierarchicalLayout.list = value;
				invalidateLayout(LayoutUpdateType.FULL);
			} else {
				_doLaterSetHierarchicalLayout = true;
			}
			//super.dataProvider = value;
			dispatchEvent(new Event("dataProviderChanged"));
		}
		
		public function get itemRendererField():String {
			return _itemRendererField;
		}
		
		public function set itemRendererField(value:String):void {
			if (_itemRendererField === value) {
				return;
			}
			_itemRendererFieldOrFunctionChanged = true;
			invalidateProperties();
		}
		
		override public function setStyle(styleProp:String, newValue:*):void {
			var len:int;
			var i:int;
			var layoutData:Object;
			var renderer:IOrganizationChartItemRenderer;
			var styleName:String;
			if (getStyle(styleProp) == newValue) { return; }
			if (_hierarchicalLayout) {
				switch (styleProp) {
					case "itemRendererSkin" :
						if (_itemRenderers) {
							len = _itemRenderers.length;
							for (i=0; i<len; i++) {
								renderer = _itemRenderers[i];
								if (!renderer.data.itemRendererSkin) {
									renderer.setStyle("skinClass", newValue);
								}
							}
						}
						break;
					case "horizontalPadding" :
						invalidateLayout(LayoutUpdateType.STATUS);
						break;
					case "verticalPadding" :
						invalidateLayout(LayoutUpdateType.STATUS);
						break;
					case "itemMinimizedWidth" :
					case "itemMinimizedHeight" :
					case "itemNormalWidth" :
					case "itemNormalHeight" :
					case "itemMaximizedWidth" :
					case "itemMaximizedHeight" :
						len = _dataProvider.length;
						styleName = 
							(styleProp == "itemMinimizedWidth") ? "minimizedWidth" :
							(styleProp == "itemMinimizedHeight") ? "minimizedHeight" :
							(styleProp == "itemNormalWidth") ? "normalWidth" :
							(styleProp == "itemNormalHeight") ? "normalHeight" :
							(styleProp == "itemMaximizedWidth") ? "maximizedWidth" :
							(styleProp == "itemMaximizedHeight") ? "maximizedHeight" : null;
						for (i=0; i<len; i++) {
							layoutData = _dataProvider.getItemAt(i);
							layoutData[styleName] = newValue;
						}
						_hierarchicalLayout.flushAndFillMemory();
						invalidateLayout(LayoutUpdateType.FULL);
						break;
				}
			}
			super.setStyle(styleProp, newValue);
		}
		
		private function injectDefaultProperties(target:IList):void {
			const len:int = target.length;
			var item:Object;
			var i:int;
			for (i=0; i<len; i++) {
				item = target.getItemAt(i);
				item.state = 0;
				item.collapsed = false;
				item.hasChildren = true;
				item.minimizedWidth = getStyle("itemMinimizedWidth") as Number;
				item.minimizedHeight = getStyle("itemMinimizedHeight") as Number;
				item.normalWidth = getStyle("itemNormalWidth") as Number;
				item.normalHeight = getStyle("itemNormalHeight") as Number;
				item.maximizedWidth = getStyle("itemMaximizedWidth") as Number;
				item.maximizedHeight = getStyle("itemMaximizedHeight") as Number;
			}
		}
		
		public function invalidateLayout(updateType:int):void {
			const horizontalPadding:Number = getStyle("horizontalPadding") as Number;
			const verticalPadding:Number = getStyle("verticalPadding") as Number;
			var timer:int = getTimer();
			if (_hierarchicalLayout) {
				_visibleItemsData = _hierarchicalLayout.calculateArea(
					new Rectangle(
						horizontalScrollPosition,
						verticalScrollPosition, 
						width, 
						height
					),
					horizontalPadding, verticalPadding, _animationFlag, updateType);
			}
			trace("Alchemy in "+(getTimer()-timer)+" ms");
			renderViewableItemsOnly();
			invalidateConnectors();
			trace("Rendering in "+(getTimer()-timer)+" ms");
		}
		
		public function invalidateConnectors():void {
			if (!hasEventListener(Event.ENTER_FRAME)) {
				addEventListener(Event.ENTER_FRAME, dataGroup_enterFrameHandler, false, 0, true);
			}
		}
		
		protected function updateConnectors():void {
			const offsetH:Number = (getStyle("horizontalPadding") as Number)*.5;
			const offsetV:Number = (getStyle("verticalPadding") as Number)*.5;
			const len:int = _visibleItemsData.length;
			const path:GraphicsPath = new GraphicsPath();
			const curve:Number = 10;
			const g:Graphics = _connectorCanvas.graphics;
			var item:IOrganizationChartItemRenderer;
			var ownerItem:IOrganizationChartItemRenderer;
			var skin:IOrganizationChartItemSkin;
			var ownerSkin:IOrganizationChartItemSkin;
			var connectorEntry:HierarchicalConnector;
			var connectorExit:HierarchicalConnector;
			var ownerConnectorEntry:HierarchicalConnector;
			var ownerConnectorExit:HierarchicalConnector;
			var directionFlag:int;
			var ownerIsVisible:Boolean;
			var i:int;
			var j:int;
			for (i=0; i<len; i++) {
				item = _itemRenderers[i];
				if (!item.disconnected) {
					if ((item.data as LayoutData).ownerId >= 0) {
						ownerIsVisible = false;
						for (j=0; j<len; j++) {
							ownerItem = _itemRenderers[j];
							if ((ownerItem.data as LayoutData).id == (item.data as LayoutData).ownerId) {
								ownerIsVisible = true;
								break;
							}
						}
						if (ownerIsVisible) {
							skin = (item as SkinnableComponent).skin as IOrganizationChartItemSkin;
							ownerSkin = (ownerItem as SkinnableComponent).skin as IOrganizationChartItemSkin;
							connectorEntry = skin.entryPoint;
							connectorExit = skin.exitPoint;
							ownerConnectorEntry = ownerSkin.entryPoint;
							ownerConnectorExit = ownerSkin.exitPoint;
							directionFlag = ((item.x+connectorEntry.x) < (ownerItem.x+ownerConnectorExit.x)) ? 0 : ((item.x+connectorEntry.x) > (ownerItem.x+ownerConnectorExit.x)) ? 1 : 2;
							if (connectorEntry.orientation == ConnectorOrientation.TOP) {
								if (Math.abs(item.x+connectorEntry.x-ownerItem.x-ownerConnectorExit.x) < curve) {
									directionFlag = 2;
								}
							} else if (connectorEntry.orientation == ConnectorOrientation.LEFT) {
								if (Math.abs(item.x+connectorEntry.x-ownerItem.x-ownerConnectorExit.x-offsetH) < offsetH) {
									directionFlag = 2;
								}
							}
							path.moveTo((ownerItem.x+ownerConnectorExit.x), (ownerItem.y+ownerConnectorExit.y));
							switch (ownerConnectorExit.orientation) {
								case ConnectorOrientation.BOTTOM :
									if (directionFlag == 0) {
										path.lineTo((ownerItem.x+ownerConnectorExit.x), (ownerItem.y+ownerItem.height+offsetV-curve));
										path.curveTo((ownerItem.x+ownerConnectorExit.x), (ownerItem.y+ownerItem.height+offsetV), (ownerItem.x+ownerConnectorExit.x-curve), (ownerItem.y+ownerItem.height+offsetV));
									} else if (directionFlag == 1) {
										path.lineTo((ownerItem.x+ownerConnectorExit.x), (ownerItem.y+ownerItem.height+offsetV-curve));
										path.curveTo((ownerItem.x+ownerConnectorExit.x), (ownerItem.y+ownerItem.height+offsetV), (ownerItem.x+ownerConnectorExit.x+curve), (ownerItem.y+ownerItem.height+offsetV));
									} else {
										path.lineTo((ownerItem.x+ownerConnectorExit.x), (ownerItem.y+ownerItem.height+offsetV));
									}
									break;
							}
							switch (connectorEntry.orientation) {
								case ConnectorOrientation.LEFT :
									if (directionFlag == 0) {
										path.lineTo((item.x+connectorEntry.x-offsetH+curve), (ownerItem.y+ownerItem.height+offsetV));
										path.curveTo((item.x+connectorEntry.x-offsetH), (ownerItem.y+ownerItem.height+offsetV), (item.x+connectorEntry.x-offsetH), (ownerItem.y+ownerItem.height+offsetV+curve));
									} else if (directionFlag == 1) {
										path.lineTo((item.x+connectorEntry.x-offsetH-curve), (ownerItem.y+ownerItem.height+offsetV));
										path.curveTo((item.x+connectorEntry.x-offsetH), (ownerItem.y+ownerItem.height+offsetV), (item.x+connectorEntry.x-offsetH), (ownerItem.y+ownerItem.height+offsetV+curve));
									}
									path.lineTo((item.x+connectorEntry.x-offsetH), (item.y+connectorEntry.y-curve));
									path.curveTo((item.x+connectorEntry.x-offsetH), (item.y+connectorEntry.y), (item.x+connectorEntry.x-offsetH+curve), (item.y+connectorEntry.y));
									path.lineTo((item.x+connectorEntry.x-offsetH+curve), (item.y+connectorEntry.y));
									path.lineTo((item.x+connectorEntry.x), (item.y+connectorEntry.y));
									break;
								case ConnectorOrientation.TOP :
									if (directionFlag == 0) {
										path.lineTo((item.x+connectorEntry.x+curve), (ownerItem.y+ownerItem.height+offsetV));
										path.curveTo((item.x+connectorEntry.x), (ownerItem.y+ownerItem.height+offsetV), (item.x+connectorEntry.x), (ownerItem.y+ownerItem.height+offsetV+curve));
										path.lineTo((item.x+connectorEntry.x), (item.y+connectorEntry.y));
									} else if (directionFlag == 1) {
										path.lineTo((item.x+connectorEntry.x-curve), (ownerItem.y+ownerItem.height+offsetV));
										path.curveTo((item.x+connectorEntry.x), (ownerItem.y+ownerItem.height+offsetV), (item.x+connectorEntry.x), (ownerItem.y+ownerItem.height+offsetV+curve));
										path.lineTo((item.x+connectorEntry.x), (item.y+connectorEntry.y));
									} else {
										path.lineTo((item.x+connectorEntry.x), (item.y+connectorEntry.y));
									}
									break;
							}
						}
					}
				}
			}
			g.clear();
			g.lineStyle(2, 0xcccccc, 1, true, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 3);
			g.drawPath(path.commands, path.data);
		}
		
		private function buildItemRenderers():void {
			const itemWidthDefinedBy:Array = ["itemMinimizedWidth", "itemNormalWidth", "itemMaximizedWidth"];
			const itemHeightDefinedBy:Array = ["itemMinimizedHeight", "itemNormalHeight", "itemMaximizedHeight"];
			var minItemWidth:Number = Number.MAX_VALUE;
			var minItemHeight:Number = Number.MAX_VALUE;
			var styleWidthValue:Number;
			var styleHeightValue:Number;
			var item:IOrganizationChartItemRenderer;
			var i:int;
			for (i=0; i<3; i++) {
				styleWidthValue = getStyle(itemWidthDefinedBy[i]) as Number;
				styleHeightValue = getStyle(itemHeightDefinedBy[i]) as Number;
				if (styleWidthValue < minItemWidth) { minItemWidth = styleWidthValue; }
				if (styleHeightValue < minItemHeight) { minItemHeight = styleHeightValue; }
			}
			const maxItemsH:int = int(int(width/minItemWidth)+1);
			const maxItemsV:int = int(height/minItemHeight);
			const numItemRenderers:int = _visibleItemsData.length;
			if (!_connectorCanvas) {
				_connectorCanvas = new UIComponent();
				addChildInternal(_connectorCanvas);
			}
			if (!_itemRenderers) {
				_itemRenderers = new Vector.<IOrganizationChartItemRenderer>();
			}
			if (_itemRenderers.length < numItemRenderers) {
				const len:int = numItemRenderers-_itemRenderers.length;
				for (i=0; i<len; i++) {
					item = itemRenderer.newInstance() as IOrganizationChartItemRenderer;
					if (!item) {
						throw new Error("ItemRenderer does not implement IOrganizationChartItemRenderer");
					} else {
						item.addEventListener(MouseEvent.CLICK, item_clickHandler, false, 0, true);
						item.addEventListener("disconnectedChange", itemRenderer_disconnectedChangeHandler, false, 0, true);
						item.addEventListener("collapsedChange", itemRenderer_collapsedChangeHandler, false, 0, true);
						item.visible = false;
						item.data = {index:i, state:0};
						addChildInternal(item as DisplayObject);
						dispatchEvent(new RendererExistenceEvent(RendererExistenceEvent.RENDERER_ADD, false, false, item, i, {state:0}));
						_itemRenderers.push(item);
					}
				}
				trace("***DEBUG*** Created "+numChildren+" and "+numElements+" items");
			}
		}
		
		private function renderViewableItemsOnly():void {
			buildItemRenderers();
			const len:int = _visibleItemsData.length;
			const tLen:int = _itemRenderers.length;
			var layoutData:LayoutData;
			var item:IOrganizationChartItemRenderer;
			var i:int;
			// temporarily remove binds
			_dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler);
			for (i=0; i<len; i++) {
				item = _itemRenderers[i];
				// temporarily remove binds
				item.removeEventListener("disconnectedChange", itemRenderer_disconnectedChangeHandler);
				item.removeEventListener("collapsedChange", itemRenderer_collapsedChangeHandler);
				layoutData = _visibleItemsData[i];
				if (_animationFlag) {
					item.animateTo(layoutData.originalX, layoutData.originalY, layoutData.x, layoutData.y);
				} else {
					item.x = layoutData.x;
					item.y = layoutData.y;
				}
				item.width = getStyle((layoutData.state == 0) ? "itemMinimizedWidth" : (layoutData.state == 1) ? "itemNormalWidth" : "itemMaximizedWidth");
				item.height = getStyle((layoutData.state == 0) ? "itemMinimizedHeight" : (layoutData.state == 1) ? "itemNormalHeight" : "itemMaximizedHeight");
				item.data = layoutData;
				item.disconnected = layoutData.disconnected;
				item.collapsed = layoutData.collapsed;
				item.hasChildren = layoutData.hasChildren;
				item.setStyle("skinClass", (item.data.itemRendererSkin) ? item.data.itemRendererSkin : getStyle("itemRendererSkin"));
				item.visible = true;
				// re-initiate binds
				item.addEventListener("disconnectedChange", itemRenderer_disconnectedChangeHandler, false, 0, true);
				item.addEventListener("collapsedChange", itemRenderer_collapsedChangeHandler, false, 0, true);
			}
			for (i=len; i<tLen; i++) {
				item = _itemRenderers[i];
				item.visible = false;
			}
			_animationFlag = false;
			dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, false, false, PropertyChangeEventKind.UPDATE, "contentWidth", contentWidth, _hierarchicalLayout.measuredWidth, this));
			dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, false, false, PropertyChangeEventKind.UPDATE, "contentHeight", contentHeight, _hierarchicalLayout.measuredHeight, this));
			// re-initiate binds
			_dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler, false, 0, true);
		}
		
		private function setupDefaultInheritingStyles():Boolean {
			const styleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration(new CSSSelector("cube.spark.components.supportClasses.HierarchicalDataGroup"), styleManager);
			styleDeclaration.defaultFactory = function():void {
				this.itemRendererSkin = OrganizationChartItemSkin;
				this.itemMinimizedWidth = 30;
				this.itemMinimizedHeight = 80;
				this.itemNormalWidth = 60;
				this.itemNormalHeight = 100;
				this.itemMaximizedWidth = 160;
				this.itemMaximizedHeight = 120;
				this.horizontalPadding = 60;
				this.verticalPadding = 60;
			}
			return true;
		}
		
		public function triggerAnimationFlag():void {
			_animationFlag = true;
			_hierarchicalLayout.takeSnapshot();
		}
		
		/**
		 *  @private
		 */
		private function addChildInternal(child:DisplayObject):DisplayObject {
			var formerParent:DisplayObjectContainer = child.parent;
			if (formerParent && !(formerParent is Loader)) {
				formerParent.removeChild(child);
			}
			var index:int = effectOverlayReferenceCount && child != effectOverlay ?
				Math.max(0, super.numChildren - 1) :
				super.numChildren;
			addingChild(child);
			$addChildAt(child, index);
			childAdded(child);
			return child;
		}
		
		/**
		 *  @private
		 */
		private function removeChildInternal(child:DisplayObject):DisplayObject {
			removingChild(child);
			$removeChild(child);
			childRemoved(child);
			return child;
		}
		
		private function hierarchicalDataGroup_resizeHandler(event:ResizeEvent):void {
			if ((width > 0) && (height > 0)) {
				invalidateLayout(LayoutUpdateType.POSITIONAL);
			}
		}
		
		private function item_clickHandler(event:MouseEvent):void {
			const item:IOrganizationChartItemRenderer = event.currentTarget as IOrganizationChartItemRenderer;
			const layoutData:LayoutData = item.data as LayoutData;
			const relatedItem:Object = _dataProvider.getItemAt(layoutData.listIndex);
			const oldState:int = relatedItem.state;
			const newState:int = (relatedItem.state < 2) ? int(relatedItem.state+1) : 0;
			relatedItem.state = layoutData.state = newState;
			_dataProvider.itemUpdated(layoutData, "state", oldState, newState);
			switch (relatedItem.state) {
				case 0 :
					dispatchEvent(new OrganizationChartEvent(OrganizationChartEvent.ITEM_MINIMIZE_STATE, layoutData.listIndex, item));
					break;
				case 1 :
					dispatchEvent(new OrganizationChartEvent(OrganizationChartEvent.ITEM_NORMAL_STATE, layoutData.listIndex, item));
					break;
				case 2 :
					dispatchEvent(new OrganizationChartEvent(OrganizationChartEvent.ITEM_MAXIMIZE_STATE, layoutData.listIndex, item));
					break;
			}
		}
		
		private function itemRenderer_disconnectedChangeHandler(event:Event):void {
			invalidateConnectors();
		}
		
		private function itemRenderer_collapsedChangeHandler(event:Event):void {
			const item:IOrganizationChartItemRenderer = event.currentTarget as IOrganizationChartItemRenderer;
			_hierarchicalLayout.writeBytes(item.data, (item.data as LayoutData).listIndex);
			triggerAnimationFlag();
			invalidateLayout(LayoutUpdateType.STATUS);
		}
		
		private function dataGroup_enterFrameHandler(event:Event):void {
			updateConnectors();
			removeEventListener(Event.ENTER_FRAME, dataGroup_enterFrameHandler);
		}
		
		override mx_internal function dataProvider_collectionChangeHandler(event:CollectionEvent):void {
			var layoutUpdateType:int = LayoutUpdateType.FULL;
			switch (event.kind) {
				case CollectionEventKind.ADD :
					break;
				case CollectionEventKind.MOVE :
					break;
				case CollectionEventKind.REFRESH :
					break;
				case CollectionEventKind.REMOVE :
					break;
				case CollectionEventKind.REPLACE :
					_hierarchicalLayout.writeBytes(_dataProvider.getItemAt(event.location), event.location);
					break;
				case CollectionEventKind.RESET :
					break;
				case CollectionEventKind.UPDATE :
					const len:int = event.items.length;
					var propertyEvent:PropertyChangeEvent;
					var listItem:Object;
					var i:int;
					layoutUpdateType = LayoutUpdateType.STATUS;
					for (i=0; i<len; i++) {
						propertyEvent = event.items[i] as PropertyChangeEvent;
						if (propertyEvent.property == "id" ||
							propertyEvent.property == "ownerId") {
							layoutUpdateType = LayoutUpdateType.FULL;
						}
						listItem = propertyEvent.source;
						_hierarchicalLayout.writeBytes(listItem, _dataProvider.getItemIndex(listItem));
					}
					break;
			}
			if ((layoutUpdateType == LayoutUpdateType.FULL) && (_dataProvider is ArrayCollection)) {
				(_dataProvider as ArrayCollection).source.sortOn("ownerId", Array.NUMERIC);
				_hierarchicalLayout.flushAndFillMemory();
			}
			if (layoutUpdateType == LayoutUpdateType.STATUS) {
				triggerAnimationFlag();
			}
			invalidateLayout(layoutUpdateType);
		}
		
		private function onCreationComplete(event:FlexEvent):void {
			_hierarchicalLayout = new HierarchicalLayout();
			if (_doLaterSetHierarchicalLayout) {
				injectDefaultProperties(_dataProvider);
				_hierarchicalLayout.list = _dataProvider;
				invalidateLayout(LayoutUpdateType.FULL);
			}
			addEventListener(ResizeEvent.RESIZE, hierarchicalDataGroup_resizeHandler, false, 0, true);
		}
	}
}