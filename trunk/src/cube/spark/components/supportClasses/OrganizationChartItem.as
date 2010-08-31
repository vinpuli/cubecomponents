package cube.spark.components.supportClasses {
	
	import cube.skins.spark.OrganizationChartItemSkin;
	import cube.spark.events.ConnectorEvent;
	import cube.spark.layouts.supportClasses.LayoutData;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponentCachePolicy;
	import mx.effects.IEffectInstance;
	import mx.events.EffectEvent;
	import mx.events.StateChangeEvent;
	import mx.managers.IFocusManager;
	import mx.styles.CSSSelector;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	import spark.components.Button;
	import spark.components.IItemRenderer;
	import spark.components.IItemRendererOwner;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.effects.Animate;
	import spark.effects.Move;
	import spark.effects.easing.Sine;
	
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
	
	public class OrganizationChartItem extends SkinnableComponent implements IOrganizationChartItemRenderer {
		
		include "../../core/Version.as";
		
		private const defaultStylesSet:Boolean = setupDefaultInheritingStyles();
		
		private var _data:Object;
		private var _itemIndex:int;
		private var _isMouseOver:Boolean = false;
		private var _disconnected:Boolean = false;
		private var _collapsed:Boolean = false;
		private var _hasChildren:Boolean = false;
		
		[SkinPart(required="false")]
		public var openButton:Button;
		
		public function OrganizationChartItem():void {
			addEventListener(MouseEvent.MOUSE_OVER, item_mouseHandler, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, item_mouseHandler, false, 0, true);
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
			//if (_data.state != oldState) {
				invalidateSkinState();
			//}
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
				return (data as LayoutData).firstName+" "+(data as LayoutData).lastName;
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
		
		public function animateTo(xFrom:Number, yFrom:Number, xTo:Number, yTo:Number):void {
			const move:Move = new Move(this);
			move.addEventListener(EffectEvent.EFFECT_UPDATE, move_updateHandler, false, 0, true);
			move.duration = 300;
			move.easer = new Sine();
			move.xFrom = xFrom;
			move.xTo = xTo;
			move.yFrom = yFrom;
			move.yTo = yTo;
			move.triggerEvent = null;
			move.play();
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
				if (getStyle("skinClass") == newValue) {
					return;
				}
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
			//event.stopPropagation();
			//event.stopImmediatePropagation();
			collapsed = !collapsed;
		}
		
		protected function move_updateHandler(event:EffectEvent):void {
			(skin as IOrganizationChartItemSkin).entryPoint.dispatchEvent(new ConnectorEvent(ConnectorEvent.CONNECTOR_LAYOUT_CHANGE));
			(skin as IOrganizationChartItemSkin).exitPoint.dispatchEvent(new ConnectorEvent(ConnectorEvent.CONNECTOR_LAYOUT_CHANGE));
		}
		
		protected function item_mouseHandler(event:MouseEvent):void {
			_isMouseOver = (event.type == MouseEvent.MOUSE_OVER);
			invalidateSkinState();
		}

	}
}