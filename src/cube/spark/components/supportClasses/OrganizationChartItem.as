package cube.spark.components.supportClasses {
	
	import cube.skins.spark.OrganizationChartItemSkin;
	import cube.skins.spark.SkinFactory;
	import cube.spark.effects.DockAnimation;
	import cube.spark.events.ConnectorEvent;
	import cube.spark.events.OrganizationChartEvent;
	import cube.spark.layouts.supportClasses.LayoutData;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	import mx.styles.CSSSelector;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.Button;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.effects.animation.MotionPath;
	import spark.filters.BlurFilter;
	
	[SkinState("minimizedUp")]
	[SkinState("normalUp")]
	[SkinState("maximizedUp")]
	[SkinState("minimizedOver")]
	[SkinState("normalOver")]
	[SkinState("maximizedOver")]
	[SkinState("minimizedDown")]
	[SkinState("normalDown")]
	[SkinState("maximizedDown")]
	[SkinState("minimizedDisabled")]
	[SkinState("normalDisabled")]
	[SkinState("maximizedDisabled")]
	
	[Style(name="cornerRadius", type="Number", inherit="no")]
	
	[Event(name="rendererSkinReady", type="cube.spark.events.OrganizationChartEvent")]
	
	public class OrganizationChartItem extends SkinnableComponent implements IOrganizationChartItemRenderer {
		
		include "../../core/Version.as";
		
		protected const defaultStylesSet:Boolean = setupDefaultInheritingStyles();
		
		protected var _data:Object;
		protected var _itemIndex:int;
		protected var _isMouseOver:Boolean = false;
		protected var _disconnected:Boolean = false;
		protected var _collapsed:Boolean = false;
		protected var _hasChildren:Boolean = false;
		protected var _skinReady:Boolean = false;
		protected var _doLaterAnimateTo:Object;
		protected var _currentAnimation:DockAnimation;
		protected var _skinFactory:SkinFactory;
		protected var _blurFilter:BlurFilter;
		protected var _animator:HierarchicalItemAnimator;
		protected var _motionPaths:Vector.<MotionPath>;
		
		[SkinPart(required="false")]
		public var openButton:Button;

		public function OrganizationChartItem():void {
			addEventListener(MouseEvent.MOUSE_DOWN, item_mouseHandler, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OVER, item_mouseHandler, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, item_mouseHandler, false, 0, true);
			addEventListener(MouseEvent.CLICK, item_mouseHandler, false, 0, true);
			super();
			
		}
		
		[Bindable("dataChange")]
		public function get data():Object {
			return _data;
		}
		public function set data(value:Object):void {
			if (_data == value) { return; }
			var oldState:int = -1;
			if (_data) {
				oldState = _data.state;
			}
			_data = value;
			invalidateSkinState();
			if (_animator) {
				_animator.stopAnimations();
			}
			dispatchEvent(new Event("dataChange"));
		}
		
		public function get itemIndex():int {
			return _itemIndex;
		}
		public function set itemIndex(value:int):void {
			_itemIndex = value;
		}
		
		[Bindable("disconnectedChange")]
		public function get disconnected():Boolean {
			return _disconnected;
		}
		public function set disconnected(value:Boolean):void {
			if (_disconnected == value) { return; }
			_data.disconnected = _disconnected = value;
			dispatchEvent(new Event("disconnectedChange"));
		}
		
		[Bindable("collapsedChange")]
		public function get collapsed():Boolean {
			return _collapsed;
		}
		public function set collapsed(value:Boolean):void {
			if (_collapsed == value) { return; }
			_data.collapsed = _collapsed = value;
			dispatchEvent(new Event("collapsedChange"));
		}
		
		[Bindable("hasChildrenChange")]
		public function get hasChildren():Boolean {
			return _hasChildren;
		}
		public function set hasChildren(value:Boolean):void {
			if (_hasChildren == value) { return; }
			_data.hasChildren = _hasChildren = value;
			dispatchEvent(new Event("hasChildrenChange"));
		}
		
		public function get dragging():Boolean {
			return false;
		}
		
		public function set dragging(value:Boolean):void {
			// void
		}
		
		[Bindable("dataChange")]
		public function get label():String {
			if (data is LayoutData) {
				return "Id: "+(data as LayoutData).id.toString()+", ownerId: "+(data as LayoutData).ownerId.toString();
			}
			return new String();
		}
		
		public function set label(value:String):void {
			// void
		}
		
		public function get selected():Boolean {
			return false;
		}
		
		public function set selected(value:Boolean):void {
			// void
		}
		
		public function get showsCaret():Boolean {
			return false;
		}
		
		public function set showsCaret(value:Boolean):void {
			// void
		}
		
		protected function get activeSkinGenerator():Class {
			return _skinFactory.activeGenerator;
		}
		
		public function get skinReady():Boolean {
			return _skinReady;
		}
		
		public function get animator():HierarchicalItemAnimator {
			return _animator;
		}
		
		public function set animator(value:HierarchicalItemAnimator):void {
			_animator = value;
		}
		
		public function get motionPaths():Vector.<MotionPath> {
			return _motionPaths;
		}
		
		public function set motionPaths(value:Vector.<MotionPath>):void {
			_motionPaths = value;
		}
		
		override protected function getCurrentSkinState():String {
			var skinState:String;
			switch (_data.state) {
				case 0 :
					skinState = "minimized";
					break;
				case 1 :
					skinState = "normal";
					break;
				case 2 :
					skinState = "maximized";
					break;
			}
			if (_isMouseOver) {
				skinState += "Over";
			} else {
				skinState += "Up";
			}
			dispatchEvent(new Event(skinState+"SkinState"));
			return skinState;
		}
		
		override public function setStyle(styleProp:String, newValue:*):void {
			if (styleProp == "skinClass") {
				_skinReady = false;
				if (!_skinFactory) {
					_skinFactory = new SkinFactory();
					super.setStyle("skinFactory", _skinFactory);
				}
				if (_skinFactory.addGenerator(newValue)) {
					styleChanged("skinFactory");
					dispatchEvent(new Event("dataChange"));
				}
				skin.addEventListener(Event.FRAME_CONSTRUCTED, skin_updateComplete, false, 0, true);
				return;
			}
			super.setStyle(styleProp, newValue);
		}
		
		override protected function partAdded(partName:String, instance:Object):void {
			if (instance == openButton) {
				openButton.addEventListener(MouseEvent.CLICK, openButton_clickHandler, false, 0, true);
			}
			super.partAdded(partName, instance);
		}
		
		override protected function findSkinParts():void {
			if (skin is IOrganizationChartItemSkin) {
				(skin as IOrganizationChartItemSkin).entryPoint.addEventListener(
					ConnectorEvent.CONNECTOR_LAYOUT_CHANGE,
					connector_layoutChangeHandler,
					false, 0, true
				);
				(skin as IOrganizationChartItemSkin).exitPoint.addEventListener(
					ConnectorEvent.CONNECTOR_LAYOUT_CHANGE,
					connector_layoutChangeHandler,
					false, 0, true
				);
			} else {
				throw new Error("Organization item skin must implement 'IOrganizationChartItemSkin' interface.");
			}
			super.findSkinParts();
		}
		
		private function setupDefaultInheritingStyles():Boolean {
			if (!styleManager.getStyleDeclaration("cube.spark.components.supportClasses.OrganizationChartItem")) {
				const styleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration(new CSSSelector("cube.spark.components.supportClasses.OrganizationChartItem"), styleManager);
				styleDeclaration.defaultFactory = function():void {
					this.skinClass = OrganizationChartItemSkin;
					this.cornerRadius = 12;
				}
				styleManager.setStyleDeclaration("cube.spark.components.supportClasses.OrganizationChartItem", styleDeclaration, true);
			}
			return true;
		}
		
		protected function connector_layoutChangeHandler(event:ConnectorEvent):void {
			if (owner) {
				(owner as HierarchicalDataGroup).invalidateConnectors();
			}
		}
		
		protected function openButton_clickHandler(event:MouseEvent):void {
			collapsed = !collapsed;
		}
		
		protected function item_mouseHandler(event:MouseEvent):void {
			_isMouseOver = (event.type == MouseEvent.MOUSE_OVER);
			invalidateSkinState();
			if (event.type == MouseEvent.MOUSE_DOWN) {
				event.stopImmediatePropagation();
				event.stopPropagation();
			}
		}
		
		protected function skin_updateComplete(event:Event):void {
			const dispatchingSkin:UIComponent = event.currentTarget as UIComponent;
			_skinReady = true;
			dispatchingSkin.removeEventListener(Event.FRAME_CONSTRUCTED, skin_updateComplete);
			dispatchEvent(new OrganizationChartEvent(
				OrganizationChartEvent.RENDERER_SKIN_READY,
				(data as LayoutData).listIndex,
				this
			));
		}

	}
}