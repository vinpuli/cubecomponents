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
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.events.ResizeEvent;
	import mx.styles.CSSSelector;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.DataGroup;
	import spark.components.ResizeMode;
	import spark.components.supportClasses.Skin;
	import spark.effects.Animate;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	import spark.effects.easing.Sine;
	import spark.events.RendererExistenceEvent;
	
	use namespace mx_internal;
	
	[Event(name="itemMinimizeState", type="cube.spark.events.OrganizationChartEvent")]
	[Event(name="itemNormalState", type="cube.spark.events.OrganizationChartEvent")]
	[Event(name="itemMaximizeState", type="cube.spark.events.OrganizationChartEvent")]
	[Event(name="updateComplete", type="cube.spark.events.OrganizationChartEvent")]
	[Event(name="collapsedChange", type="cube.spark.events.OrganizationChartEvent")]
	[Event(name="disconnectedChange", type="cube.spark.events.OrganizationChartEvent")]
	
	[Style(name="itemMinimizedWidth", type="Number", format="Length", inherit="no")]
	[Style(name="itemMinimizedHeight", type="Number", format="Length", inherit="no")]
	[Style(name="itemNormalWidth", type="Number", format="Length", inherit="no")]
	[Style(name="itemNormalHeight", type="Number", format="Length", inherit="no")]
	[Style(name="itemMaximizedWidth", type="Number", format="Length", inherit="no")]
	[Style(name="itemMaximizedHeight", type="Number", format="Length", inherit="no")]
	[Style(name="itemRendererSkin", type="Class", inherit="no")]
	[Style(name="horizontalPadding", type="Number", format="Length", inherit="no")]
	[Style(name="verticalPadding", type="Number", format="Length", inherit="no")]
	
	[ResourceBundle("components")]
	
	[DefaultProperty("dataProvider")]
	
	public class HierarchicalDataGroup extends DataGroup {
		
		include "../../core/Version.as";
		
		private const defaultStylesSet:Boolean = setupDefaultInheritingStyles();
		
		private var _dragPane:UIComponent;
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
		private var _pendingUpdateType:int = 0;
		private var _autoFocusTarget:int = -1;
		private var _autoFocusTargetOnUpdate:int = -1;
		private var _currentFocusAnimation:Animate;
		private var _centerPos:Point;
		private var _ignoreLayoutDelta:Boolean = false;
		
		public function HierarchicalDataGroup():void {
			addEventListener(FlexEvent.CREATION_COMPLETE, self_creationCompleteHandler, false, 0, true);
		}
		
		override public function set horizontalScrollPosition(value:Number):void {
			super.horizontalScrollPosition = value;
			renderDragPane();
		}
		
		override public function set verticalScrollPosition(value:Number):void {
			super.verticalScrollPosition = value;
			renderDragPane();
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
				(_dataProvider as ArrayCollection).source.sort(dataProvider_sortFunction);
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
		
		public function get visibleItemsData():Vector.<LayoutData> {
			return _visibleItemsData;
		}
		
		public function get connectorCanvas():UIComponent {
			return _connectorCanvas;
		}
		
		public function get itemRenderers():Vector.<IOrganizationChartItemRenderer> {
			return _itemRenderers;
		}
		
		public function get actualWidth():Number {
			return (resizeMode == ResizeMode.SCALE) ? measuredWidth : unscaledWidth;
		}
		
		public function get actualHeight():Number {
			return (resizeMode == ResizeMode.SCALE) ? measuredHeight : unscaledHeight;
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
						invalidateLayout(LayoutUpdateType.STATUS);
						break;
					case "connectorLineColor" :
					case "connectorLineAlpha" :
					case "connectorLineThickness" :
						invalidateConnectors();
						break;
				}
			}
			super.setStyle(styleProp, newValue);
		}
		
		public function setItemRendererStyle(styleProp:String, newValue:*):void {
			if (!_itemRenderers) { return; }
			const len:int = _itemRenderers.length;
			var itemRenderer:IOrganizationChartItemRenderer;
			var i:int;
			for (i=0; i<len; i++) {
				itemRenderer = _itemRenderers[i];
				itemRenderer.setStyle(styleProp, newValue);
			}
			super.setStyle(styleProp, newValue);
		}
		
		mx_internal override function drawBackground():void {
			return;
		}
		
		public function invalidateLayout(updateType:int):void {
			_pendingUpdateType = (updateType > _pendingUpdateType) ? updateType : _pendingUpdateType;
			addEventListener(Event.ENTER_FRAME, dataGroup_invalidateHandler, false, 0, true);
		}
		
		public function invalidateConnectors():void {
			if (!hasEventListener(Event.ENTER_FRAME)) {
				addEventListener(Event.ENTER_FRAME, dataGroup_enterFrameHandler, false, 0, true);
			}
		}
		
		mx_internal function focus(target:*):void {
			if (target is int) {
				_autoFocusTarget = target as int;
			} else {
				if (target.data) {
					if (target.data.id >= 0) {
						_autoFocusTarget = target.data.id;
					}
				}
			}
			applyFocus();
		}
		
		protected function delayedInvalidateLayout():void {
			const horizontalPadding:Number = getStyle("horizontalPadding") as Number;
			const verticalPadding:Number = getStyle("verticalPadding") as Number;
			const area:Rectangle = new Rectangle(
				horizontalScrollPosition,
				verticalScrollPosition, 
				width, 
				height
			);
			var timer:int = getTimer();
			var newVisibleItemsData:Vector.<LayoutData>;
			if (_hierarchicalLayout) {
				newVisibleItemsData = _hierarchicalLayout.calculateArea(area, horizontalPadding, verticalPadding, _animationFlag, _pendingUpdateType);
			}
			if (_visibleItemsData) {
				resetLayoutForNewItems(newVisibleItemsData);
			}
			_visibleItemsData = newVisibleItemsData;
			trace("Alchemy in "+(getTimer()-timer)+" ms (updateType: "+_pendingUpdateType+")");
			_pendingUpdateType = 0;
			renderViewableItemsOnly();
			invalidateConnectors();
			dispatchEvent(new OrganizationChartEvent(OrganizationChartEvent.UPDATE_COMPLETE, -1, null));
			applyFocus();
			trace("Rendering in "+(getTimer()-timer)+" ms");
		}
		
		protected function resetLayoutForNewItems(newItemsList:Vector.<LayoutData>):void {
			const nLen:int = newItemsList.length;
			const oLen:int = _visibleItemsData.length;
			var layoutData:LayoutData;
			var compareLayoutData:LayoutData;
			var i:int;
			var j:int;
			for (i=0; i<nLen; i++) {
				layoutData = newItemsList[i];
				layoutData.layoutDelta = false;
				for (j=0; j<oLen; j++) {
					compareLayoutData = _visibleItemsData[j];
					if (layoutData.id == compareLayoutData.id) {
						layoutData.layoutDelta = true;
						break;
					}
				}
			}
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
			if (!itemRenderer) {
				const itemRendererStyle:Object = getStyle("itemRenderer");
				if (itemRendererStyle is IFactory) {
					itemRenderer = itemRendererStyle as IFactory;
				} else if (itemRendererStyle is Class) {
					itemRenderer = new ClassFactory(itemRendererStyle as Class);
				}
				if (!itemRenderer) { itemRenderer = new ClassFactory(OrganizationChartItem); }
			}
			if (!_dragPane) {
				_dragPane = new UIComponent();
				renderDragPane();
				addChildInternal(_dragPane, 0);
			}
			if (!_connectorCanvas) {
				_connectorCanvas = new UIComponent();
				_connectorCanvas.mouseEnabled = _connectorCanvas.mouseChildren = false;
				addChildInternal(_connectorCanvas, 0);
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
						item.setStyle("cornerRadius", getStyle("cornerRadius"));
						item.addEventListener(MouseEvent.CLICK, item_clickHandler, false, 0, true);
						item.addEventListener("disconnectedChange", itemRenderer_disconnectedChangeHandler, false, 0, true);
						item.addEventListener("collapsedChange", itemRenderer_collapsedChangeHandler, false, 0, true);
						item.visible = false;
						item.includeInLayout = false;
						item.data = {index:i, state:0};
						addChildInternal(item as DisplayObject, 2);
						dispatchEvent(new RendererExistenceEvent(RendererExistenceEvent.RENDERER_ADD, false, false, item, i, {state:0}));
						_itemRenderers.push(item);
					}
				}
				//trace("***DEBUG*** Created "+numChildren+" and "+numElements+" items");
			}
		}
		
		private function renderViewableItemsOnly():void {
			buildItemRenderers();
			const len:int = _visibleItemsData.length;
			const tLen:int = _itemRenderers.length;
			var layoutData:LayoutData;
			var item:IOrganizationChartItemRenderer;
			var dw:Number;
			var dh:Number;
			var i:int;
			// temporarily remove binds
			_dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler);
			for (i=0; i<len; i++) {
				item = _itemRenderers[i];
				// temporarily remove binds
				item.removeEventListener("disconnectedChange", itemRenderer_disconnectedChangeHandler);
				item.removeEventListener("collapsedChange", itemRenderer_collapsedChangeHandler);
				layoutData = _visibleItemsData[i];
				if (item.data != layoutData) {
					item.x = layoutData.x;
					item.y = layoutData.y;
				}
				dw = getStyle((layoutData.state == 0) ? "itemMinimizedWidth" : (layoutData.state == 1) ? "itemNormalWidth" : "itemMaximizedWidth");
				dh = getStyle((layoutData.state == 0) ? "itemMinimizedHeight" : (layoutData.state == 1) ? "itemNormalHeight" : "itemMaximizedHeight");
				item.width = dw;
				item.height = dh;
				item.data = layoutData;
				item.disconnected = layoutData.disconnected;
				item.collapsed = layoutData.collapsed;
				item.hasChildren = layoutData.hasChildren;
				item.setStyle("skinClass", (layoutData.itemRendererSkin) ? layoutData.itemRendererSkin : getStyle("itemRendererSkin"));
				item.visible = true;
				handleLayoutUpdate(item, layoutData);
				layoutData.layoutDelta = true;
				// re-initiate binds
				item.addEventListener(OrganizationChartEvent.DISCONNECTED_CHANGE, itemRenderer_disconnectedChangeHandler, false, 0, true);
				item.addEventListener(OrganizationChartEvent.COLLAPSED_CHANGE, itemRenderer_collapsedChangeHandler, false, 0, true);
			}
			for (i=len; i<tLen; i++) {
				item = _itemRenderers[i];
				//layoutData.layoutDelta = false;
				handleLayoutUpdate(item);
				//item.visible = false;
			}
			_animationFlag = false;
			_ignoreLayoutDelta = false;
			dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, false, false, PropertyChangeEventKind.UPDATE, "contentWidth", contentWidth, _hierarchicalLayout.measuredWidth, this));
			dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, false, false, PropertyChangeEventKind.UPDATE, "contentHeight", contentHeight, _hierarchicalLayout.measuredHeight, this));
			// re-initiate binds
			_dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler, false, 0, true);
		}
		
		private function handleLayoutUpdate(item:IOrganizationChartItemRenderer, layoutData:LayoutData=null):void {
			const isAppearEffect:Boolean = !_ignoreLayoutDelta;
			const animator:HierarchicalItemAnimator = item.animator ? item.animator : new HierarchicalItemAnimator();
			if (layoutData) {
				if (_animationFlag && (!layoutData.layoutDelta || _ignoreLayoutDelta)) {
					animator.addMotion(
						item, 
						{
							x: layoutData.layoutDelta ? item.x : (_centerPos ? _centerPos.x : mouseX),
							y: layoutData.layoutDelta ? item.y : (_centerPos ? _centerPos.y : mouseY),
							alpha: layoutData.layoutDelta ? 1 : 0
						}, 
						{
							x: layoutData.x,
							y: layoutData.y,
							alpha: 1
						},
						isAppearEffect
					);
				} else {
					item.x = layoutData.x;
					item.y = layoutData.y;
					item.alpha = 1;
				}
				animator.endHandler = null;
			} else if (_animationFlag) {
				animator.addMotion(
					item, 
					{
						x: item.x,
						y: item.y,
						alpha: 1
					}, 
					{
						x: item.x,
						y: item.y,
						alpha: 0
					},
					true, true
				);
				animator.endHandler = 
					function():void {
						item.visible = false;
					};
			} else {
				if (item.animator) {
					item.animator.stopAnimations();
				}
				item.visible = false;
			}
			item.animator = animator;
		}
		
		private function applyFocus():void {
			if ((_autoFocusTarget >= 0) && (getStyle("autoFocusItems") == true)) {
				_centerPos = _hierarchicalLayout.getAbsoluteCenter(_autoFocusTarget);
				if ((_centerPos.x < 0) && (_centerPos.y < 0)) {
					_autoFocusTargetOnUpdate = _autoFocusTarget;
				} else {
					if (_currentFocusAnimation && (_currentFocusAnimation.isPlaying)) {
						_currentFocusAnimation.removeEventListener(EffectEvent.EFFECT_END, animation_effectEndHandler);
						_currentFocusAnimation.end();
						//invalidateLayout(LayoutUpdateType.POSITIONAL);
					}
					_currentFocusAnimation = new Animate(this);
					const hPos:Number = Math.min((_centerPos.x-width/2), (_hierarchicalLayout.measuredWidth-width));
					const vPos:Number = Math.min((_centerPos.y-height/2), (_hierarchicalLayout.measuredHeight-height));
					const xPath:SimpleMotionPath = new SimpleMotionPath("horizontalScrollPosition", horizontalScrollPosition, hPos, 1);
					const yPath:SimpleMotionPath = new SimpleMotionPath("verticalScrollPosition", verticalScrollPosition, vPos, 1);
					const motionPaths:Vector.<MotionPath> = new Vector.<MotionPath>(2, true);
					motionPaths[0] = xPath;
					motionPaths[1] = yPath;
					_currentFocusAnimation.addEventListener(EffectEvent.EFFECT_END, animation_effectEndHandler, false, 0, true);
					_currentFocusAnimation.motionPaths = motionPaths;
					_currentFocusAnimation.duration = 300;
					_currentFocusAnimation.easer = new Sine();
					_currentFocusAnimation.triggerEvent = null;
					_currentFocusAnimation.startDelay = 50;
					_currentFocusAnimation.play();
				}
			}
			_autoFocusTarget = -1;
		}
		
		private function setupDefaultInheritingStyles():Boolean {
			if (!styleManager.getStyleDeclaration("cube.spark.components.supportClasses.HierarchicalDataGroup")) {
				const styleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration(new CSSSelector("cube.spark.components.supportClasses.HierarchicalDataGroup"), styleManager);
				styleDeclaration.defaultFactory = function():void {
					this.itemRenderer = new ClassFactory(OrganizationChartItem);
					this.itemRendererSkin = OrganizationChartItemSkin;
					this.itemMinimizedWidth = 30;
					this.itemMinimizedHeight = 80;
					this.itemNormalWidth = 60;
					this.itemNormalHeight = 100;
					this.itemMaximizedWidth = 160;
					this.itemMaximizedHeight = 120;
					this.horizontalPadding = 60;
					this.verticalPadding = 60;
					this.cornerRadius = 12;
					this.connectorLineColor = 0xcccccc;
					this.connectorLineAlpha = 1;
					this.connectorLineThickness = 2;
				}
				styleManager.setStyleDeclaration("cube.spark.components.supportClasses.HierarchicalDataGroup", styleDeclaration, true);
			}
			return true;
		}
		
		private function renderDragPane():void {
			if (_dragPane) {
				if (_dragPane && (_dragPane.width != width) && (_dragPane.height != height)) {
					const g:Graphics = _dragPane.graphics;
					g.clear();
					g.beginFill(0x000000, 0);
					g.drawRect(0, 0, width, height);
					g.endFill();
				}
				_dragPane.x = horizontalScrollPosition;
				_dragPane.y = verticalScrollPosition;
			}
		}
		
		public function triggerAnimationFlag(invalidateLayoutDeltas:Boolean=false):void {
			_animationFlag = true;
			_hierarchicalLayout.takeSnapshot();
			_ignoreLayoutDelta = invalidateLayoutDeltas;
		}
		
		/**
		 *  @private
		 */
		private function addChildInternal(child:DisplayObject, index:int=0):DisplayObject {
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
		
		private function animation_effectEndHandler(event:EffectEvent):void {
			const animation:Animate = event.currentTarget as Animate;
			animation.removeEventListener(EffectEvent.EFFECT_END, animation_effectEndHandler);
			invalidateLayout(LayoutUpdateType.POSITIONAL);
			_centerPos = null;
		}
		
		private function hierarchicalDataGroup_resizeHandler(event:ResizeEvent):void {
			if ((width > 0) && (height > 0)) {
				renderDragPane();
				invalidateLayout(LayoutUpdateType.POSITIONAL);
			}
		}
		
		private function item_clickHandler(event:MouseEvent):void {
			if (!(event.target is Skin)) {
				return;
			}
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
			_autoFocusTarget = item.data.id;
			triggerAnimationFlag(true);
		}
		
		private function itemRenderer_disconnectedChangeHandler(event:Event):void {
			const item:IOrganizationChartItemRenderer = event.currentTarget as IOrganizationChartItemRenderer;
			invalidateConnectors();
			dispatchEvent(new OrganizationChartEvent(OrganizationChartEvent.DISCONNECTED_CHANGE, (item.data as LayoutData).listIndex, item));
		}
		
		private function itemRenderer_collapsedChangeHandler(event:Event):void {
			const item:IOrganizationChartItemRenderer = event.currentTarget as IOrganizationChartItemRenderer;
			_hierarchicalLayout.writeBytes((item.data as LayoutData), (item.data as LayoutData).listIndex);
			_autoFocusTarget = (item.data as LayoutData).id;
			triggerAnimationFlag(true);
			invalidateLayout(LayoutUpdateType.STATUS);
			dispatchEvent(new OrganizationChartEvent(OrganizationChartEvent.COLLAPSED_CHANGE, (item.data as LayoutData).listIndex, item));
		}
		
		private function dataGroup_enterFrameHandler(event:Event):void {
			removeEventListener(Event.ENTER_FRAME, dataGroup_enterFrameHandler);
			HierarchicalConnectorRenderer.updateConnectors(this);
		}
		
		private function dataGroup_invalidateHandler(event:Event):void {
			removeEventListener(Event.ENTER_FRAME, dataGroup_invalidateHandler);
			delayedInvalidateLayout();
		}
		
		override mx_internal function dataProvider_collectionChangeHandler(event:CollectionEvent):void {
			var layoutUpdateType:int = LayoutUpdateType.FULL;
			switch (event.kind) {
				case CollectionEventKind.ADD :
					if ((_autoFocusTarget == -1) && event.items && (event.items.length > 0)) {
						_autoFocusTarget = (event.items[0] as LayoutData).id;
					}
					triggerAnimationFlag();
					break;
				case CollectionEventKind.MOVE :
					break;
				case CollectionEventKind.REFRESH :
					break;
				case CollectionEventKind.REMOVE :
					break;
				case CollectionEventKind.REPLACE :
					_hierarchicalLayout.writeBytes((_dataProvider.getItemAt(event.location) as LayoutData), event.location);
					break;
				case CollectionEventKind.RESET :
					break;
				case CollectionEventKind.UPDATE :
					const len:int = event.items.length;
					var propertyEvent:PropertyChangeEvent;
					var listItem:LayoutData;
					var i:int;
					layoutUpdateType = LayoutUpdateType.STATUS;
					for (i=0; i<len; i++) {
						propertyEvent = event.items[i] as PropertyChangeEvent;
						if (propertyEvent.property == "id" ||
							propertyEvent.property == "ownerId") {
							layoutUpdateType = LayoutUpdateType.FULL;
						}
						listItem = propertyEvent.source as LayoutData;
						_hierarchicalLayout.writeBytes(listItem, _dataProvider.getItemIndex(listItem));
					}
					break;
			}
			if (_autoFocusTargetOnUpdate >= 0) {
				_autoFocusTarget = _autoFocusTargetOnUpdate;
				_autoFocusTargetOnUpdate = -1;
			}
			if ((layoutUpdateType == LayoutUpdateType.FULL) && (_dataProvider is ArrayCollection)) {
				(_dataProvider as ArrayCollection).source.sort(dataProvider_sortFunction);
				_hierarchicalLayout.flushAndFillMemory();
			}
			if (layoutUpdateType == LayoutUpdateType.STATUS) {
				triggerAnimationFlag();
			}
			invalidateLayout(layoutUpdateType);
			invalidateConnectors();
		}
		
		private function dataProvider_sortFunction(itemA:Object, itemB:Object):int {
			const valA:Number = itemA.ownerId-(1/itemA.id);
			const valB:Number = itemB.ownerId-(1/itemB.id);
			if (valA > valB) {
				return 1;
			} else if (valA < valB) {
				return -1;
			}
			return 0;
		}
		
		private function self_creationCompleteHandler(event:FlexEvent):void {
			_hierarchicalLayout = new HierarchicalLayout();
			if (_doLaterSetHierarchicalLayout) {
				_hierarchicalLayout.list = _dataProvider;
				invalidateLayout(LayoutUpdateType.FULL);
			}
			removeEventListener(FlexEvent.CREATION_COMPLETE, self_creationCompleteHandler);
			addEventListener(ResizeEvent.RESIZE, hierarchicalDataGroup_resizeHandler, false, 0, true);
		}
	}
}