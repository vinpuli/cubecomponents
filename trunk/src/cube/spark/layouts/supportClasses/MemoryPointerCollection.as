package cube.spark.layouts.supportClasses {
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public final class MemoryPointerCollection {
		
		private var _hasChildrenBytes:ByteArray;
		private var _visibleItemsBytes:ByteArray;
		private var _ownerVisibleItemsBytes:ByteArray;
		private var _idBytes:ByteArray;
		private var _ownerIdBytes:ByteArray;
		private var _minimizedWidthBytes:ByteArray;
		private var _minimizedHeightBytes:ByteArray;
		private var _normalWidthBytes:ByteArray;
		private var _normalHeightBytes:ByteArray;
		private var _maximizedWidthBytes:ByteArray;
		private var _maximizedHeightBytes:ByteArray;
		private var _stateBytes:ByteArray;
		private var _collapsedBytes:ByteArray;
		private var _xPosBytes:ByteArray;
		private var _yPosBytes:ByteArray;
		
		private var _hasChildrenPointer:int;
		private var _visibleItemsPointer:int;
		private var _ownerVisibleItemsPointer:int;
		private var _idPointer:int;
		private var _ownerIdPointer:int;
		private var _minimizedWidthPointer:int;
		private var _minimizedHeightPointer:int;
		private var _normalWidthPointer:int;
		private var _normalHeightPointer:int;
		private var _maximizedWidthPointer:int;
		private var _maximizedHeightPointer:int;
		private var _statePointer:int;
		private var _collapsedPointer:int;
		private var _xPosPointer:int;
		private var _yPosPointer:int;
		
		public function get hasChildrenBytes():ByteArray {
			if (!_hasChildrenBytes) {
				_hasChildrenBytes = new ByteArray();
				_hasChildrenBytes.endian = Endian.LITTLE_ENDIAN;
			}
			return _hasChildrenBytes;
		}
		
		public function get visibleItemsBytes():ByteArray {
			if (!_visibleItemsBytes) {
				_visibleItemsBytes = new ByteArray();
				_visibleItemsBytes.endian = Endian.LITTLE_ENDIAN;
			}
			return _visibleItemsBytes;
		}
		
		public function get ownerVisibleItemsBytes():ByteArray {
			if (!_ownerVisibleItemsBytes) {
				_ownerVisibleItemsBytes = new ByteArray();
				_ownerVisibleItemsBytes.endian = Endian.LITTLE_ENDIAN;
			}
			return _ownerVisibleItemsBytes;
		}
		
		public function get idBytes():ByteArray {
			if (!_idBytes) {
				_idBytes = new ByteArray();
				_idBytes.endian = Endian.LITTLE_ENDIAN;
			}
			return _idBytes;
		}
		
		public function get ownerIdBytes():ByteArray {
			if (!_ownerIdBytes) {
				_ownerIdBytes = new ByteArray();
				_ownerIdBytes.endian = Endian.LITTLE_ENDIAN;
			}
			return _ownerIdBytes;
		}
		
		public function get minimizedWidthBytes():ByteArray {
			if (!_minimizedWidthBytes) {
				_minimizedWidthBytes = new ByteArray();
				_minimizedWidthBytes.endian = Endian.LITTLE_ENDIAN;
			}
			return _minimizedWidthBytes;
		}
		
		public function get minimizedHeightBytes():ByteArray {
			if (!_minimizedHeightBytes) {
				_minimizedHeightBytes = new ByteArray();
				_minimizedHeightBytes.endian = Endian.LITTLE_ENDIAN;
			}
			return _minimizedHeightBytes;
		}
		
		public function get normalWidthBytes():ByteArray {
			if (!_normalWidthBytes) {
				_normalWidthBytes = new ByteArray();
				_normalWidthBytes.endian = Endian.LITTLE_ENDIAN;
			}
			return _normalWidthBytes;
		}
		
		public function get normalHeightBytes():ByteArray {
			if (!_normalHeightBytes) {
				_normalHeightBytes = new ByteArray();
				_normalHeightBytes.endian = Endian.LITTLE_ENDIAN;
			}
			return _normalHeightBytes;
		}
		
		public function get maximizedWidthBytes():ByteArray {
			if (!_maximizedWidthBytes) {
				_maximizedWidthBytes = new ByteArray();
				_maximizedWidthBytes.endian = Endian.LITTLE_ENDIAN;
			}
			return _maximizedWidthBytes;
		}
		
		public function get maximizedHeightBytes():ByteArray {
			if (!_maximizedHeightBytes) {
				_maximizedHeightBytes = new ByteArray();
				_maximizedHeightBytes.endian = Endian.LITTLE_ENDIAN;
			}
			return _maximizedHeightBytes;
		}
		
		public function get stateBytes():ByteArray {
			if (!_stateBytes) {
				_stateBytes = new ByteArray();
				_stateBytes.endian = Endian.LITTLE_ENDIAN;
			}
			return _stateBytes;
		}
		
		public function get collapsedBytes():ByteArray {
			if (!_collapsedBytes) {
				_collapsedBytes = new ByteArray();
				_collapsedBytes.endian = Endian.LITTLE_ENDIAN;
			}
			return _collapsedBytes;
		}
		
		public function get xPosBytes():ByteArray {
			if (!_xPosBytes) {
				_xPosBytes = new ByteArray();
				_xPosBytes.endian = Endian.LITTLE_ENDIAN;
			}
			return _xPosBytes;
		}
		
		public function get yPosBytes():ByteArray {
			if (!_yPosBytes) {
				_yPosBytes = new ByteArray();
				_yPosBytes.endian = Endian.LITTLE_ENDIAN;
			}
			return _yPosBytes;
		}
		
		public function get hasChildrenPointer():int {
			return _hasChildrenPointer;
		}
		
		public function set hasChildrenPointer(value:int):void {
			_hasChildrenPointer = value;
		}
		
		public function get visibleItemsPointer():int {
			return _visibleItemsPointer;
		}
		
		public function set visibleItemsPointer(value:int):void {
			_visibleItemsPointer = value;
		}
		
		public function get ownerVisibleItemsPointer():int {
			return _ownerVisibleItemsPointer;
		}
		
		public function set ownerVisibleItemsPointer(value:int):void {
			_ownerVisibleItemsPointer = value;
		}
		
		public function get idPointer():int {
			return _idPointer;
		}
		
		public function set idPointer(value:int):void {
			_idPointer = value;
		}
		
		public function get ownerIdPointer():int {
			return _ownerIdPointer;
		}
		
		public function set ownerIdPointer(value:int):void {
			_ownerIdPointer = value;
		}
		
		public function get minimizedWidthPointer():int {
			return _minimizedWidthPointer;
		}
		
		public function set minimizedWidthPointer(value:int):void {
			_minimizedWidthPointer = value;
		}
		
		public function get minimizedHeightPointer():int {
			return _minimizedHeightPointer;
		}
		
		public function set minimizedHeightPointer(value:int):void {
			_minimizedHeightPointer = value;
		}
		
		public function get normalWidthPointer():int {
			return _normalWidthPointer;
		}
		
		public function set normalWidthPointer(value:int):void {
			_normalWidthPointer = value;
		}
		
		public function get normalHeightPointer():int {
			return _normalHeightPointer;
		}
		
		public function set normalHeightPointer(value:int):void {
			_normalHeightPointer = value;
		}
		
		public function get maximizedWidthPointer():int {
			return _maximizedWidthPointer;
		}
		
		public function set maximizedWidthPointer(value:int):void {
			_maximizedWidthPointer = value;
		}
		
		public function get maximizedHeightPointer():int {
			return _maximizedHeightPointer;
		}
		
		public function set maximizedHeightPointer(value:int):void {
			_maximizedHeightPointer = value;
		}
		
		public function get statePointer():int {
			return _statePointer;
		}
		
		public function set statePointer(value:int):void {
			_statePointer = value;
		}
		
		public function get collapsedPointer():int {
			return _collapsedPointer;
		}
		
		public function set collapsedPointer(value:int):void {
			_collapsedPointer = value;
		}
		
		public function get xPosPointer():int {
			return _xPosPointer;
		}
		
		public function set xPosPointer(value:int):void {
			_xPosPointer = value;
		}
		
		public function get yPosPointer():int {
			return _yPosPointer;
		}
		
		public function set yPosPointer(value:int):void {
			_yPosPointer = value;
		}
		
		public function flush():void {
			visibleItemsBytes.clear();
			idBytes.clear();
			ownerIdBytes.clear();
			minimizedWidthBytes.clear();
			minimizedHeightBytes.clear();
			normalWidthBytes.clear();
			normalHeightBytes.clear();
			maximizedWidthBytes.clear();
			maximizedHeightBytes.clear();
			stateBytes.clear();
			xPosBytes.clear();
			yPosBytes.clear();
			collapsedBytes.clear();
			hasChildrenBytes.clear();
		}
	}
}