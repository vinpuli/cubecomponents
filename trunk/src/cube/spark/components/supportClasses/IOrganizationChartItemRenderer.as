package cube.spark.components.supportClasses {
	
	import mx.core.IFlexDisplayObject;
	import mx.core.IStateClient2;
	import mx.core.IVisualElement;
	import mx.styles.IStyleClient;
	
	import spark.components.IItemRenderer;
	import spark.effects.animation.MotionPath;
	
	public interface IOrganizationChartItemRenderer extends IItemRenderer, IStyleClient, IStateClient2 {
		
		function get disconnected():Boolean;
		function get collapsed():Boolean;
		function get hasChildren():Boolean;
		function get skinReady():Boolean;
		function get animator():HierarchicalItemAnimator;
		function get filters():Array;
		function get motionPaths():Vector.<MotionPath>;
		
		function set disconnected(value:Boolean):void;
		function set collapsed(value:Boolean):void;
		function set hasChildren(value:Boolean):void;
		function set animator(value:HierarchicalItemAnimator):void;
		function set filters(value:Array):void;
		function set motionPaths(value:Vector.<MotionPath>):void;
		
	}
}