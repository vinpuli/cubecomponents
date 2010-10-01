package cube.spark.components.supportClasses {
	
	import cube.spark.effects.DockAnimation;
	import cube.spark.events.ConnectorEvent;
	import cube.spark.events.OrganizationChartEvent;
	
	import mx.events.EffectEvent;
	
	import spark.components.supportClasses.SkinnableComponent;
	import spark.effects.Animate;
	import spark.effects.easing.Elastic;
	import spark.effects.easing.Linear;
	import spark.effects.easing.Power;
	import spark.effects.easing.Sine;
	import spark.filters.BlurFilter;
	
	public final class HierarchicalItemAnimator {
		
		private var _target:IOrganizationChartItemRenderer;
		private var _currentAnimation:Animate;
		private var _startPositions:Object;
		private var _endPositions:Object;
		private var _animationBlurFilter:BlurFilter;
		private var _isAppearEffect:Boolean;
		private var _endHandler:Function;
		
		public function HierarchicalItemAnimator():void {
		}
		
		public function set endHandler(value:Function):void {
			_endHandler = value;
		}
		
		public function addMotion(target:IOrganizationChartItemRenderer, startPositions:Object, endPositions:Object, isAppearEffect:Boolean=true, doNotEvaluate:Boolean=false):void {
			if (target.visible) {
				_target = target;
				_startPositions = startPositions;
				_endPositions = endPositions;
				_isAppearEffect = isAppearEffect;
				stopAnimations();
				if (target.skinReady) {
					if (doNotEvaluate || validatePositions()) {
						applyPosition(_startPositions);
						_animationBlurFilter = new BlurFilter(80, 80);
						if (_isAppearEffect) {
							_target.filters = [_animationBlurFilter];
						}
						_currentAnimation = createAnimationHandler();
						_currentAnimation.play();
					} else {
						target.filters = null;
						applyPosition(_endPositions);
						move_updateHandler();
					}
				} else {
					_target.addEventListener(OrganizationChartEvent.RENDERER_SKIN_READY, target_rendererSkinReadyHandler, false, 0, true);
				}
			}
		}
		
		public function stopAnimations():void {
			if (_currentAnimation && _currentAnimation.isPlaying) {
				_currentAnimation.removeEventListener(EffectEvent.EFFECT_UPDATE, move_updateHandler);
				_currentAnimation.end();
			}
		}
		
		private function applyPosition(position:Object):void {
			var property:String;
			for (property in position) {
				_target[property] = position[property];
			}
		}
		
		private function validatePositions():Boolean {
			const returnValue:Boolean = !(
				isNaN(_startPositions.x) ||
				isNaN(_startPositions.y) || 
				(
					(_startPositions.x == _endPositions.x) && 
					(_startPositions.y == _endPositions.y)
				)
			);
			return returnValue;
		}
		
		private function createAnimationHandler(explicitDuration:int=-1):Animate {
			const animate:DockAnimation = new DockAnimation(_target);
			animate.addEventListener(EffectEvent.EFFECT_UPDATE, move_updateHandler, false, 0, true);
			animate.addEventListener(EffectEvent.EFFECT_END,  move_updateHandler, false, 0, true);
			animate.addEventListener(EffectEvent.EFFECT_STOP,  move_updateHandler, false, 0, true);
			animate.duration = (explicitDuration > 0) ? explicitDuration : Math.min(
				800, (Math.abs(_endPositions.x-_startPositions.x)+300)
			);
			animate.easer = new Sine(0);
			if (_target.motionPaths) {
				animate.motionPaths = _target.motionPaths;
			}
			animate.xFrom = _startPositions.x;
			animate.xTo = _endPositions.x;
			animate.yFrom = _startPositions.y;
			animate.yTo = _endPositions.y;
			animate.alphaTo = _endPositions.alpha;
			animate.alphaFrom = _startPositions.alpha;
			animate.triggerEvent = null;
			animate.suspendBackgroundProcessing = true;
			return animate;
		}
		
		private function move_updateHandler(event:EffectEvent=null):void {
			const skin:IOrganizationChartItemSkin = (_target as SkinnableComponent).skin as IOrganizationChartItemSkin;
			skin.entryPoint.dispatchEvent(new ConnectorEvent(ConnectorEvent.CONNECTOR_LAYOUT_CHANGE));
			if (!event || (event.type == EffectEvent.EFFECT_END)) {
				_target.filters = null;
				if (_endHandler != null) {
					_endHandler();
					_endHandler = null;
				}
			} else {
				_animationBlurFilter.blurX *= .9;
				_animationBlurFilter.blurY *= .9;
			}
		}
		
		private function target_rendererSkinReadyHandler(event:OrganizationChartEvent):void {
			_target.removeEventListener(OrganizationChartEvent.RENDERER_SKIN_READY, target_rendererSkinReadyHandler);
			addMotion(_target, _startPositions, _endPositions, _isAppearEffect);
		}
	}
}