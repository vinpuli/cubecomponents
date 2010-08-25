package cube.spark.components.supportClasses {
	
	import mx.core.IStateClient2;
	import mx.styles.IStyleClient;
	
	import spark.components.IItemRenderer;
	
	public interface IOrganizationChartItemRenderer extends IItemRenderer, IStyleClient, IStateClient2 {
		
		function get disconnected():Boolean;
		
		function set disconnected(value:Boolean):void;
		
		function animateTo(xFrom:Number, yFrom:Number, xTo:Number, yTo:Number):void;
		
	}
}