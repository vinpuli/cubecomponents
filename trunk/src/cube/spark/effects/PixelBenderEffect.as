package cube.spark.effects {
	
	import flash.display.Shader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.filters.ShaderFilter;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.EffectEvent;
	
	[Event(name="effectStart", type="mx.events.EffectEvent.EffectEvent")]
	[Event(name="effectUpdate", type="mx.events.EffectEvent.EffectEvent")]
	[Event(name="effectEnd", type="mx.events.EffectEvent.EffectEvent")]
	
	public class PixelBenderEffect extends EventDispatcher {
		
		private var _target:UIComponent;
		private var _shader:Shader;
		private var _shaderFilter:ShaderFilter;
		private var _updateData:Object;
		private var _startData:Object;
		private var _endData:Object;
		private var _renderedFrames:int;
		private var _numFrames:int;

		public function get shader():Shader {
			return _shader;
		}

		public function set shader(value:Shader):void {
			_shader = value;
			_shaderFilter = new ShaderFilter(value);
		}

		public function get target():UIComponent {
			return _target;
		}

		public function set target(value:UIComponent):void {
			_target = value;
		}

		public function PixelBenderEffect():void {
			super();
		}
		
		public function start(startData:Object, endData:Object, duration:int):void {
			var property:String;
			var len:int;
			var i:int;
			_renderedFrames = 0;
			_numFrames = int(duration/FlexGlobals.topLevelApplication.stage.frameRate);
			_startData = startData;
			_endData = endData;
			_target.filters = [_shaderFilter];
			_updateData = new Object();
			for (property in startData) {
				if (startData[property] is Array) {
					len = (startData[property] as Array).length;
					_updateData[property] = new Array();
					for (i=0; i<len; i++) {
						(_updateData[property] as Array)[i] = ((endData[property] as Array)[i]-(startData[property] as Array)[i])/_numFrames;
					}
				} else {
					_updateData[property] = (endData[property]-startData[property])/_numFrames;
				}
			}
			updateShader(_startData, false);
			addListeners();
			dispatchEvent(new EffectEvent(EffectEvent.EFFECT_START));
		}
		
		public function stop():void {
			stopAndApplyState(_endData);
		}
		
		public function reset():void {
			stopAndApplyState(_startData);
		}
		
		private function stopAndApplyState(state:Object):void {
			updateShader(state, false);
			removeListeners();
			_target.filters = null;
			dispatchEvent(new EffectEvent(EffectEvent.EFFECT_END));
		}
		
		private function addListeners():void {
			_target.addEventListener(Event.ENTER_FRAME, self_enterFrameHandler, false, 0, true);
		}
		
		private function removeListeners():void {
			_target.removeEventListener(Event.ENTER_FRAME, self_enterFrameHandler);
		}
		
		private function updateShader(updateData:Object, isAddition:Boolean=true):void {
			var property:String;
			var len:int;
			var i:int;
			for (property in updateData) {
				if (isAddition) {
					if (updateData[property] is Array) {
						len = (updateData[property] as Array).length;
						for (i=0; i<len; i++) {
							_shader.data[property].value[i] += (updateData[property] as Array)[i];
						}
					} else {
						_shader.data[property].value[0] += updateData[property];
					}
				} else {
					if (updateData[property] is Array) {
						_shader.data[property].value = updateData[property];
					} else {
						_shader.data[property].value = [updateData[property]];
					}
				}
			}
			_target.filters = [_shaderFilter];
			if (isAddition) {
				dispatchEvent(new EffectEvent(EffectEvent.EFFECT_UPDATE));
			}
		}
		
		private function durationTimer_timerHandler(event:TimerEvent):void {
			updateShader(_updateData);
		}
		
		private function durationTimer_timerCompleteHandler(event:TimerEvent):void {
			stop();
		}
		
		private function self_enterFrameHandler(event:Event):void {
			if (_renderedFrames >= _numFrames) {
				stop();
			} else {
				_renderedFrames++;
				updateShader(_updateData, true);
			}
		}
	}
}