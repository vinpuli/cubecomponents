package cube.spark.components.supportClasses {
	
	import cube.spark.layouts.supportClasses.LayoutData;
	
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.GraphicsPath;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	
	import spark.components.supportClasses.SkinnableComponent;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	
	public class HierarchicalConnectorRenderer {
		
		include "../../core/Version.as";
		
		private var _lastArgs:Array;
		
		public function HierarchicalConnectorRenderer():void {
		}
		
		public static function updateConnectors(target:HierarchicalDataGroup):void {
			var w:Number = target.actualWidth;
			var h:Number = target.actualHeight;
			if (isNaN(w) || isNaN(h)) {
				return;
			}
			const instance:HierarchicalConnectorRenderer = new HierarchicalConnectorRenderer();
			const offsetH:Number = (target.getStyle("horizontalPadding") as Number)*.5;
			const offsetV:Number = (target.getStyle("verticalPadding") as Number)*.5;
			const len:int = target.visibleItemsData.length;
			const path:GraphicsPath = new GraphicsPath();
			const curve:Number = 10;
			const g:Graphics = target.connectorCanvas.graphics;
			var motionPaths:Vector.<MotionPath>;
			var item:IOrganizationChartItemRenderer;
			var ownerItem:IOrganizationChartItemRenderer;
			var skin:IOrganizationChartItemSkin;
			var ownerSkin:IOrganizationChartItemSkin;
			var connectorEntry:HierarchicalConnector;
			var connectorExit:HierarchicalConnector;
			var ownerConnectorEntry:HierarchicalConnector;
			var ownerConnectorExit:HierarchicalConnector;
			var directionFlag:int;
			var ownerIsVisible:Boolean;
			var i:int;
			var j:int;
			var pathLen:int;
			for (i=0; i<len; i++) {
				item = target.itemRenderers[i];
				motionPaths = new Vector.<MotionPath>();
				if (!item.disconnected) {
					if ((item.data as LayoutData).ownerId >= 0) {
						ownerIsVisible = false;
						for (j=0; j<len; j++) {
							ownerItem = target.itemRenderers[j];
							if ((ownerItem.data as LayoutData).id == (item.data as LayoutData).ownerId) {
								ownerIsVisible = true;
								break;
							}
						}
						if (ownerIsVisible) {
							skin = (item as SkinnableComponent).skin as IOrganizationChartItemSkin;
							ownerSkin = (ownerItem as SkinnableComponent).skin as IOrganizationChartItemSkin;
							connectorEntry = skin.entryPoint;
							connectorExit = skin.exitPoint;
							ownerConnectorEntry = ownerSkin.entryPoint;
							ownerConnectorExit = ownerSkin.exitPoint;
							directionFlag = ((item.x+connectorEntry.x) < (ownerItem.x+ownerConnectorExit.x)) ? 0 : ((item.x+connectorEntry.x) > (ownerItem.x+ownerConnectorExit.x)) ? 1 : 2;
							if (connectorEntry.orientation == ConnectorOrientation.TOP) {
								if (Math.abs(item.x+connectorEntry.x-ownerItem.x-ownerConnectorExit.x) < curve) {
									directionFlag = 2;
								}
							} else if (connectorEntry.orientation == ConnectorOrientation.LEFT) {
								if (Math.abs(item.x+connectorEntry.x-ownerItem.x-ownerConnectorExit.x-offsetH) < offsetH) {
									directionFlag = 2;
								}
							} else if (connectorEntry.orientation == ConnectorOrientation.RIGHT) {
								if (Math.abs(item.x+connectorEntry.x-ownerItem.x-ownerConnectorExit.x+offsetH) < offsetH) {
									directionFlag = 2;
								}
							}
							instance.apply(path, motionPaths, "moveTo", (ownerItem.x+ownerConnectorExit.x), (ownerItem.y+ownerConnectorExit.y));
							switch (ownerConnectorExit.orientation) {
								case ConnectorOrientation.BOTTOM :
									if (directionFlag == 0) {
										instance.apply(path, motionPaths, "lineTo", (ownerItem.x+ownerConnectorExit.x), (ownerItem.y+ownerItem.height+offsetV-curve));
										instance.apply(path, motionPaths, "curveTo", (ownerItem.x+ownerConnectorExit.x), (ownerItem.y+ownerItem.height+offsetV), (ownerItem.x+ownerConnectorExit.x-curve), (ownerItem.y+ownerItem.height+offsetV));
									} else if (directionFlag == 1) {
										instance.apply(path, motionPaths, "lineTo", (ownerItem.x+ownerConnectorExit.x), (ownerItem.y+ownerItem.height+offsetV-curve));
										instance.apply(path, motionPaths, "curveTo", (ownerItem.x+ownerConnectorExit.x), (ownerItem.y+ownerItem.height+offsetV), (ownerItem.x+ownerConnectorExit.x+curve), (ownerItem.y+ownerItem.height+offsetV));
									} else {
										instance.apply(path, motionPaths, "lineTo", (ownerItem.x+ownerConnectorExit.x), (ownerItem.y+ownerItem.height+offsetV));
									}
									break;
							}
							pathLen = path.data.length;
							switch (connectorEntry.orientation) {
								case ConnectorOrientation.LEFT :
									if (directionFlag == 0) {
										optimizeNextLineTo(path, path.data[int(pathLen-2)], path.data[int(pathLen-1)], (item.x+connectorEntry.x-offsetH+curve), (ownerItem.y+ownerItem.height+offsetV));
										instance.apply(path, motionPaths, "curveTo", (item.x+connectorEntry.x-offsetH), (ownerItem.y+ownerItem.height+offsetV), (item.x+connectorEntry.x-offsetH), (ownerItem.y+ownerItem.height+offsetV+curve));
									} else if (directionFlag == 1) {
										optimizeNextLineTo(path, path.data[int(pathLen-2)], path.data[int(pathLen-1)], (item.x+connectorEntry.x-offsetH-curve), (ownerItem.y+ownerItem.height+offsetV));
										instance.apply(path, motionPaths, "curveTo", (item.x+connectorEntry.x-offsetH), (ownerItem.y+ownerItem.height+offsetV), (item.x+connectorEntry.x-offsetH), (ownerItem.y+ownerItem.height+offsetV+curve));
									}
									instance.apply(path, motionPaths, "lineTo", (item.x+connectorEntry.x-offsetH), (item.y+connectorEntry.y-curve));
									instance.apply(path, motionPaths, "curveTo", (item.x+connectorEntry.x-offsetH), (item.y+connectorEntry.y), (item.x+connectorEntry.x-offsetH+curve), (item.y+connectorEntry.y));
									instance.apply(path, motionPaths, "lineTo", (item.x+connectorEntry.x-offsetH+curve), (item.y+connectorEntry.y));
									instance.apply(path, motionPaths, "lineTo", (item.x+connectorEntry.x), (item.y+connectorEntry.y));
									break;
								case ConnectorOrientation.RIGHT :
									if (directionFlag == 0) {
										optimizeNextLineTo(path, path.data[int(pathLen-2)], path.data[int(pathLen-1)], (item.x+connectorEntry.x+offsetH+curve), (ownerItem.y+ownerItem.height+offsetV));
										instance.apply(path, motionPaths, "curveTo", (item.x+connectorEntry.x+offsetH), (ownerItem.y+ownerItem.height+offsetV), (item.x+connectorEntry.x+offsetH), (ownerItem.y+ownerItem.height+offsetV+curve));
									} else if (directionFlag == 1) {
										optimizeNextLineTo(path, path.data[int(pathLen-2)], path.data[int(pathLen-1)], (item.x+connectorEntry.x+offsetH-curve), (ownerItem.y+ownerItem.height+offsetV));
										instance.apply(path, motionPaths, "curveTo", (item.x+connectorEntry.x+offsetH), (ownerItem.y+ownerItem.height+offsetV), (item.x+connectorEntry.x+offsetH), (ownerItem.y+ownerItem.height+offsetV+curve));
									}
									instance.apply(path, motionPaths, "lineTo", (item.x+connectorEntry.x+offsetH), (item.y+connectorEntry.y-curve));
									instance.apply(path, motionPaths, "curveTo", (item.x+connectorEntry.x+offsetH), (item.y+connectorEntry.y), (item.x+connectorEntry.x+offsetH-curve), (item.y+connectorEntry.y));
									instance.apply(path, motionPaths, "lineTo", (item.x+connectorEntry.x+offsetH-curve), (item.y+connectorEntry.y));
									instance.apply(path, motionPaths, "lineTo", (item.x+connectorEntry.x), (item.y+connectorEntry.y));
									break;
								case ConnectorOrientation.TOP :
									if (directionFlag == 0) {
										optimizeNextLineTo(path, path.data[int(pathLen-2)], path.data[int(pathLen-1)], (item.x+connectorEntry.x+curve), (ownerItem.y+ownerItem.height+offsetV));
										instance.apply(path, motionPaths, "curveTo", (item.x+connectorEntry.x), (ownerItem.y+ownerItem.height+offsetV), (item.x+connectorEntry.x), (ownerItem.y+ownerItem.height+offsetV+curve));
										instance.apply(path, motionPaths, "lineTo", (item.x+connectorEntry.x), (item.y+connectorEntry.y));
									} else if (directionFlag == 1) {
										optimizeNextLineTo(path, path.data[int(pathLen-2)], path.data[int(pathLen-1)], (item.x+connectorEntry.x-curve), (ownerItem.y+ownerItem.height+offsetV));
										instance.apply(path, motionPaths, "curveTo", (item.x+connectorEntry.x), (ownerItem.y+ownerItem.height+offsetV), (item.x+connectorEntry.x), (ownerItem.y+ownerItem.height+offsetV+curve));
										instance.apply(path, motionPaths, "lineTo", (item.x+connectorEntry.x), (item.y+connectorEntry.y));
									} else {
										instance.apply(path, motionPaths, "lineTo", (item.x+connectorEntry.x), (item.y+connectorEntry.y));
									}
									break;
							}
						}
					}
				}
				item.motionPaths = motionPaths;
			}
			g.clear();
			g.lineStyle(
				target.getStyle("connectorLineThickness"), 
				target.getStyle("connectorLineColor"), 
				target.getStyle("connectorLineAlpha"), 
				true, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.MITER, 1.414);
			g.drawPath(path.commands, path.data);
		}
		
		protected static function optimizeNextLineTo(path:GraphicsPath, dx:Number, dy:Number, tx:Number, ty:Number):void {
			const dist:Number = Math.abs(tx-dx);
			const maxVal:int = 10000;
			if (dist > maxVal) {
				const cnt:int = int(dist/maxVal);
				const val:int = (tx > dx) ? maxVal : -maxVal;
				var i:int;
				for (i=1; i<cnt; i++) {
					path.lineTo(dx+val*i, ty);
				}
			}
			path.lineTo(tx, ty);
		}
		
		private function apply(drawPath:GraphicsPath, motionPaths:Vector.<MotionPath>, method:String, ...args:Array):void {
			(drawPath[method] as Function).apply(drawPath, args);
			if (_lastArgs) {
				switch (method) {
					case "moveTo" : case "lineTo" :
						motionPaths.push(new SimpleMotionPath("x", (_lastArgs ? _lastArgs[0] : 0), args[0]));
						motionPaths.push(new SimpleMotionPath("y", (_lastArgs ? _lastArgs[1] : 0), args[1]));
						break;
					case "curveTo" :
						break;
				}
			}
			_lastArgs = args;
		}
		
	}
}