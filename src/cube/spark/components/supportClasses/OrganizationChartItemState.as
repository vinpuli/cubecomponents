package cube.spark.components.supportClasses {
	
	public final class OrganizationChartItemState {
		
		public function OrganizationChartItemState():void {
			throw new ArgumentError("Static use only.");
		}
		
		public static const MINIMIZED:int = 0;
		public static const NORMAL:int = 1;
		public static const MAXIMIZED:int = 2;
		
	}
}