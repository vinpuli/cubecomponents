package cube.spark.layouts {
	
	import cmodule.OrganizationChartLayout.CLibInit;
	
	import cube.spark.components.supportClasses.HierarchicalDataGroup;
	import cube.spark.layouts.supportClasses.LayoutData;
	import cube.spark.layouts.supportClasses.LayoutUpdateType;
	import cube.spark.layouts.supportClasses.MemoryPointerCollection;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	
	public class HierarchicalLayout {
		
		include "../core/Version.as";
		
		private var _clib:Object;
		
		private var _list:IList;
		private var _cByteSize:int;
		private var _memory:ByteArray;
		private var _memoryPointerCollection:MemoryPointerCollection;
		private var _snapshotXBytes:ByteArray;
		private var _snapshotYBytes:ByteArray;
		private var _measuredWidth:Number;
		private var _measuredHeight:Number;
		private var _owner:HierarchicalDataGroup;
		
		public function HierarchicalLayout():void {
			initialize();
		}
		
		public function get list():IList {
			return _list;
		}
		
		public function set list(value:IList):void {
			_list = value;
			flushAndFillMemory();
		}
		
		public function get measuredWidth():Number {
			return _measuredWidth;
		}
		
		public function get measuredHeight():Number {
			return _measuredHeight;
		}
		
		public function takeSnapshot():void {
			_snapshotXBytes = new ByteArray();
			_snapshotYBytes = new ByteArray();
			_snapshotXBytes.endian = _memory.endian;
			_snapshotYBytes.endian = _memory.endian;
			_memory.position = _memoryPointerCollection.xPosPointer;
			_memory.readBytes(_snapshotXBytes, 0, _list.length*4);
			_memory.position = _memoryPointerCollection.yPosPointer;
			_memory.readBytes(_snapshotYBytes, 0, _list.length*4);
			_memory.position =  _memoryPointerCollection.xPosPointer;
		}
		
		public function getAbsoluteCenter(id:int):Point {
			const result:Array = _clib.getAbsoluteCenter(id);
			return new Point(result[0], result[1]);
		}
		
		public function calculateArea(area:Rectangle, horizontalPadding:Number, verticalPadding:Number, includeOldLayout:Boolean, updateType:int):Vector.<LayoutData> {
			const timer:int = getTimer();
			const measuredSize:Array = _clib.calculate(horizontalPadding, verticalPadding, area.x, area.y, area.width, area.height, updateType);
			const numVisibleItems:int = measuredSize.pop() as int;
			const layoutDataCollection:Vector.<LayoutData> = new Vector.<LayoutData>(numVisibleItems, true);
			var layoutData:LayoutData;
			var memoryIndex:int;
			var property:String;
			var ownerMemoryIndex:int;
			var state:int;
			var collapsed:int;
			var hasChildren:int;
			var i:int;
			for (i=0; i<numVisibleItems; i++) {
				_memory.position = _memoryPointerCollection.visibleItemsPointer+4*i;
				memoryIndex = _memory.readInt();
				layoutData = _list.getItemAt(memoryIndex) as LayoutData;
				_memory.position = _memoryPointerCollection.ownerVisibleItemsPointer+4*i;
				ownerMemoryIndex = _memory.readInt();
				_memory.position = _memoryPointerCollection.idPointer+4*memoryIndex;
				layoutData.id = _memory.readInt();
				_memory.position = _memoryPointerCollection.ownerIdPointer+4*memoryIndex;
				layoutData.ownerId = _memory.readInt();
				_memory.position = _memoryPointerCollection.xPosPointer+4*memoryIndex;
				layoutData.x = _memory.readFloat();
				_memory.position = _memoryPointerCollection.yPosPointer+4*memoryIndex;
				layoutData.y = _memory.readFloat();
				if (includeOldLayout) {
					_snapshotXBytes.position = memoryIndex*4;
					_snapshotYBytes.position = memoryIndex*4;
					layoutData.originalX = _snapshotXBytes.readFloat();
					layoutData.originalY = _snapshotYBytes.readFloat();
				}
				_memory.position = _memoryPointerCollection.hasChildrenPointer+4*memoryIndex;
				hasChildren = _memory.readInt();
				layoutData.hasChildren = (hasChildren == 1);
				_memory.position = _memoryPointerCollection.collapsedPointer+4*memoryIndex;
				collapsed = _memory.readInt();
				layoutData.collapsed = (collapsed == 1);
				_memory.position = _memoryPointerCollection.statePointer+4*memoryIndex;
				layoutData.state = _memory.readInt();
				layoutData.listIndex = memoryIndex;
				layoutData.ownerListIndex = ownerMemoryIndex;
				layoutDataCollection[i] = layoutData;
			}
			if (includeOldLayout) {
				_snapshotXBytes.clear();
				_snapshotYBytes.clear();
			}
			if (updateType > 0) {
				_measuredWidth = measuredSize[0] as Number;
				_measuredHeight = measuredSize[1] as Number;
			}
			return layoutDataCollection;
		}
		
		private function initialize():void {
			if (!_clib) {
				const cLibInit:CLibInit = new CLibInit();
				const ns:Namespace = new Namespace("cmodule.OrganizationChartLayout");
				_clib = cLibInit.init();
				_memory = (ns::gstate).ds;
			}
		}
		
		public function flushAndFillMemory():void {
			flushMemory();
			fillMemory();
		}
		
		private function flushMemory():void {
			_clib.flushBuffers();
			_cByteSize = _clib.initializeBuffers(_list.length);
			createMemoryPointers();
		}
		
		private function fillMemory():void {
			const len:int = _list.length;
			var listItem:LayoutData;
			var i:int;
			for (i=0; i<len; i++) {
				listItem = _list.getItemAt(i) as LayoutData;
				_memoryPointerCollection.idBytes.writeInt(listItem.id);
				_memoryPointerCollection.ownerIdBytes.writeInt(listItem.ownerId);
				_memoryPointerCollection.minimizedWidthBytes.writeFloat(listItem.minimizedWidth);
				_memoryPointerCollection.minimizedHeightBytes.writeFloat(listItem.minimizedHeight);
				_memoryPointerCollection.normalWidthBytes.writeFloat(listItem.normalWidth);
				_memoryPointerCollection.normalHeightBytes.writeFloat(listItem.normalHeight);
				_memoryPointerCollection.maximizedWidthBytes.writeFloat(listItem.maximizedWidth);
				_memoryPointerCollection.maximizedHeightBytes.writeFloat(listItem.maximizedHeight);
				_memoryPointerCollection.stateBytes.writeInt(listItem.state);
				_memoryPointerCollection.collapsedBytes.writeInt(listItem.collapsed ? 1 : 0);
			}
			_memory.position = _memoryPointerCollection.idPointer;
			_memory.writeBytes(_memoryPointerCollection.idBytes);
			_memory.position = _memoryPointerCollection.ownerIdPointer;
			_memory.writeBytes(_memoryPointerCollection.ownerIdBytes);
			_memory.position = _memoryPointerCollection.minimizedWidthPointer;
			_memory.writeBytes(_memoryPointerCollection.minimizedWidthBytes);
			_memory.position = _memoryPointerCollection.minimizedHeightPointer;
			_memory.writeBytes(_memoryPointerCollection.minimizedHeightBytes);
			_memory.position = _memoryPointerCollection.normalWidthPointer;
			_memory.writeBytes(_memoryPointerCollection.normalWidthBytes);
			_memory.position = _memoryPointerCollection.normalHeightPointer;
			_memory.writeBytes(_memoryPointerCollection.normalHeightBytes);
			_memory.position = _memoryPointerCollection.maximizedWidthPointer;
			_memory.writeBytes(_memoryPointerCollection.maximizedWidthBytes);
			_memory.position = _memoryPointerCollection.maximizedHeightPointer;
			_memory.writeBytes(_memoryPointerCollection.maximizedHeightBytes);
			_memory.position = _memoryPointerCollection.statePointer;
			_memory.writeBytes(_memoryPointerCollection.stateBytes);
			_memory.position = _memoryPointerCollection.collapsedPointer;
			_memory.writeBytes(_memoryPointerCollection.collapsedBytes);
			_memoryPointerCollection.flush();
		}
		
		public function writeBytes(layoutData:LayoutData, listIndex:int=-1):void {
			const listIndex:int = (listIndex >= 0) ? listIndex : layoutData.listIndex;
			_memory.position = _memoryPointerCollection.idPointer+4*listIndex;
			_memory.writeInt(layoutData.id);
			_memory.position = _memoryPointerCollection.ownerIdPointer+4*listIndex;
			_memory.writeInt(layoutData.ownerId);
			_memory.position = _memoryPointerCollection.statePointer+4*listIndex;
			_memory.writeInt(layoutData.state);
			_memory.position = _memoryPointerCollection.collapsedPointer+4*listIndex;
			_memory.writeInt(layoutData.collapsed ? 1 : 0);
		}
		
		private function createMemoryPointers():void {
			_memoryPointerCollection = new MemoryPointerCollection();
			_memoryPointerCollection.hasChildrenPointer = _clib.getDataPointerForHasChildren();
			_memoryPointerCollection.visibleItemsPointer = _clib.getDataPointerForVisibleItems();
			_memoryPointerCollection.ownerVisibleItemsPointer = _clib.getDataPointerForOwnerVisibleItems();
			_memoryPointerCollection.idPointer = _clib.getDataPointerForId();
			_memoryPointerCollection.ownerIdPointer = _clib.getDataPointerForOwnerId();
			_memoryPointerCollection.minimizedWidthPointer = _clib.getDataPointerForMinimizedWidth();
			_memoryPointerCollection.minimizedHeightPointer = _clib.getDataPointerForMinimizedHeight();
			_memoryPointerCollection.normalWidthPointer = _clib.getDataPointerForNormalWidth();
			_memoryPointerCollection.normalHeightPointer = _clib.getDataPointerForNormalHeight();
			_memoryPointerCollection.maximizedWidthPointer = _clib.getDataPointerForMaximizedWidth();
			_memoryPointerCollection.maximizedHeightPointer = _clib.getDataPointerForMaximizedHeight();
			_memoryPointerCollection.statePointer = _clib.getDataPointerForState();
			_memoryPointerCollection.collapsedPointer = _clib.getDataPointerForCollapsed();
			_memoryPointerCollection.xPosPointer = _clib.getDataPointerForXPos();
			_memoryPointerCollection.yPosPointer = _clib.getDataPointerForYPos();
		}
	}
}