package cube.spark.components.supportClasses {
	
	import cube.spark.events.ScrollDragHandlerEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.EventPriority;
	import mx.managers.CursorManager;
	import mx.managers.CursorManagerPriority;
	
	import spark.components.DataGroup;
	
	[Event(name="scrollDrag", type="cube.spark.events.ScrollDragHandlerEvent")]
	
	public class ScrollDragHandler extends EventDispatcher {
		
		[Embed(source="assets/move_16.png")]
		private static const _MOVE_ICON:Class;
		
		private var _target:DataGroup;
		private var _dragInitPosition:Point = new Point();
		
		public function ScrollDragHandler():void {
		}
		
		public function get target():DataGroup {
			return _target;
		}
		
		public function set target(value:DataGroup):void {
			_target = value;
			if (value) {
				addListeners();
			}
		}
		
		private function addListeners():void {
			_target.addEventListener(MouseEvent.MOUSE_DOWN, target_mouseDownHandler, false, EventPriority.EFFECT, true);
			_target.addEventListener(MouseEvent.MOUSE_UP, target_mouseUpHandler, false, 0, true);
		}
		
		private function removeListeners():void {
			_target.removeEventListener(MouseEvent.MOUSE_DOWN, target_mouseDownHandler);
			_target.removeEventListener(MouseEvent.MOUSE_UP, target_mouseUpHandler);
			_target.removeEventListener(MouseEvent.MOUSE_MOVE, target_mouseMoveHandler);
			_target.removeEventListener(MouseEvent.MOUSE_MOVE, target_dragHandler);
		}
		
		private function target_mouseDownHandler(event:MouseEvent):void {
			_dragInitPosition.x = _target.mouseX;
			_dragInitPosition.y = _target.mouseY;
			_target.stage.addEventListener(MouseEvent.MOUSE_MOVE, target_mouseMoveHandler, false, 0, true);
		}
		
		private function target_mouseUpHandler(event:MouseEvent):void {
			_target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, target_mouseMoveHandler);
			_target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, target_dragHandler);
			event.stopImmediatePropagation();
			event.stopPropagation();
			CursorManager.removeAllCursors();
		}
		
		private function target_mouseMoveHandler(event:MouseEvent):void {
			const currentPosition:Point = new Point(event.stageX, event.stageY);
			const distanceDragged:Number = Point.distance(_dragInitPosition, currentPosition);
			if (distanceDragged > 10) {
				CursorManager.setCursor(_MOVE_ICON, CursorManagerPriority.HIGH, -8, -8);
				_dragInitPosition = currentPosition;
				_target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, target_mouseMoveHandler);
				_target.stage.addEventListener(MouseEvent.MOUSE_MOVE, target_dragHandler, false, 0, true);
			}
		}
		
		private function target_dragHandler(event:MouseEvent):void {
			const dx:Number = event.stageX-_dragInitPosition.x;
			const dy:Number = event.stageY-_dragInitPosition.y;
			_dragInitPosition = new Point(event.stageX, event.stageY);
			_target.horizontalScrollPosition -= dx*2;
			_target.verticalScrollPosition -= dy*2;
			dispatchEvent(new ScrollDragHandlerEvent(ScrollDragHandlerEvent.SCROLL_DRAG));
		}
	}
}