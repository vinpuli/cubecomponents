package cube.spark.layouts.supportClasses {
	
	public dynamic final class LayoutData {
		
		private var _originalX:Number;
		private var _originalY:Number;
		private var _initialX:Number;
		private var _initialY:Number;
		private var _x:Number;
		private var _y:Number;
		private var _state:int;
		private var _id:int;
		private var _ownerId:int;
		private var _listIndex:int;
		private var _ownerListIndex:int;
		private var _disconnected:Boolean;
		private var _collapsed:Boolean;
		private var _hasChildren:Boolean;
		
		public function get originalX():Number {
			return _originalX;
		}
		
		public function set originalX(value:Number):void {
			_originalX = value;
		}
		
		public function get originalY():Number {
			return _originalY;
		}
		
		public function set originalY(value:Number):void {
			_originalY = value;
		}
		
		public function get initialX():Number {
			return _initialX;
		}
		
		public function set initialX(value:Number):void {
			_initialX = value;
		}
		
		public function get initialY():Number {
			return _initialY;
		}
		
		public function set initialY(value:Number):void {
			_initialY = value;
		}
		
		public function get x():Number {
			return _x;
		}
		
		public function set x(value:Number):void {
			_x = value;
		}
		
		public function get y():Number {
			return _y;
		}
		
		public function set y(value:Number):void {
			_y = value;
		}
		
		public function get state():int {
			return _state;
		}
		
		public function set state(value:int):void {
			_state = value;
		}
		
		public function get id():int {
			return _id;
		}
		
		public function set id(value:int):void {
			_id = value;
		}
		
		public function get ownerId():int {
			return _ownerId;
		}
		
		public function set ownerId(value:int):void {
			_ownerId = value;
		}
		
		public function get listIndex():int {
			return _listIndex;
		}
		
		public function set listIndex(value:int):void {
			_listIndex = value;
		}
		
		public function get ownerListIndex():int {
			return _ownerListIndex;
		}
		
		public function set ownerListIndex(value:int):void {
			_ownerListIndex = value;
		}
		
		public function get disconnected():Boolean {
			return _disconnected;
		}
		
		public function set disconnected(value:Boolean):void {
			_disconnected = value;
		}
		
		public function get collapsed():Boolean {
			return _collapsed;
		}
		
		public function set collapsed(value:Boolean):void {
			_collapsed = value;
		}
		
		public function get hasChildren():Boolean {
			return _hasChildren;
		}
		
		public function set hasChildren(value:Boolean):void {
			_hasChildren = value;
		}
	}
}