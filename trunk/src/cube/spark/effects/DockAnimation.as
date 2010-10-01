package cube.spark.effects {
	
	import flash.geom.Vector3D;
	
	import mx.core.mx_internal;
	import mx.effects.IEffectInstance;
	
	import spark.effects.AnimateTransform;
	import spark.effects.animation.MotionPath;
	import spark.effects.supportClasses.AnimateTransformInstance;
	
	use namespace mx_internal;
	
	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------
	
	[Exclude(name="motionPaths", kind="property")]
	
	public class DockAnimation extends AnimateTransform {
		
		private static var AFFECTED_PROPERTIES:Array =
			["translationX", "translationY", 
				"postLayoutTranslationX","postLayoutTranslationY",
				"left", "right", "top", "bottom",
				"horizontalCenter", "verticalCenter", "baseline",
				"width", "height", "alpha", "filters"];
		
		private static var RELEVANT_STYLES:Array = 
			["left", "right", "top", "bottom",
				"horizontalCenter", "verticalCenter", "baseline"];
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function DockAnimation(target:Object=null):void {
			super(target);
			instanceClass = AnimateTransformInstance;
			transformEffectSubclass = true;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		[Inspectable(category="General", defaultValue="NaN")]
		
		public var yBy:Number;
		
		[Inspectable(category="General", defaultValue="NaN")]
		
		public var yFrom:Number;
		
		[Inspectable(category="General", defaultValue="NaN")]
		
		public var yTo:Number;
		
		[Inspectable(category="General", defaultValue="NaN")]
		
		public var xBy:Number;
		
		[Inspectable(category="General", defaultValue="NaN")]
		
		public var xFrom:Number;
		
		[Inspectable(category="General", defaultValue="NaN")]
		
		public var xTo:Number;
		
		[Inspectable(category="General", defaultValue="NaN")]
		
		public var alphaBy:Number;
		
		[Inspectable(category="General", defaultValue="NaN")]
		
		public var alphaFrom:Number;
		
		[Inspectable(category="General", defaultValue="NaN")]
		
		public var alphaTo:Number;
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		override public function get relevantStyles():Array {
			return RELEVANT_STYLES;
		}   
		
		override public function getAffectedProperties():Array {
			return AFFECTED_PROPERTIES;
		}
		
		override public function createInstance(target:Object = null):IEffectInstance {
			motionPaths = new Vector.<MotionPath>();
			return super.createInstance(target);
		}
		
		override protected function initInstance(instance:IEffectInstance):void {
			if (!applyChangesPostLayout) {
				addMotionPath("translationX", xFrom, xTo, xBy);
				addMotionPath("translationY", yFrom, yTo, yBy);
			} else {
				addMotionPath("postLayoutTranslationX", xFrom, xTo, xBy);
				addMotionPath("postLayoutTranslationY", yFrom, yTo, yBy);
			}
			addMotionPath("alpha", alphaFrom, alphaTo, alphaBy);
			super.initInstance(instance);
		}    
	}
}
