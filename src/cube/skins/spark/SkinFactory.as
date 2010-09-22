package cube.skins.spark {
	
	import mx.core.IFactory;
	
	import spark.components.supportClasses.Skin;
	
	public class SkinFactory implements IFactory {
		
		private var _generators:Vector.<Class>;
		private var _instances:Vector.<Skin>;
		private var _activeGenerator:Class;
		
		public function SkinFactory():void {
		}
		
		public function get activeGenerator():Class {
			return _activeGenerator;
		}
		
		public function newInstance():* {
			if (!_instances) {
				_instances = new Vector.<Skin>();
			}
			const len:int = _instances.length;
			var skin:Skin;
			var i:int;
			for (i=0; i<len; i++) {
				skin = _instances[i];
				if (skin is _activeGenerator) {
					return skin;
				}
			}
			skin = new _activeGenerator() as Skin;
			_instances.push(skin);
			return skin;
		}
		
		public function addGenerator(generator:Class):Boolean {
			if (!_generators) {
				_generators = new Vector.<Class>();
			}
			const len:int = _generators.length;
			const generatorChanged:Boolean = (_activeGenerator != generator);
			var i:int;
			_activeGenerator = generator;
			for (i=0; i<len; i++) {
				if (_generators[i] == generator) {
					return generatorChanged;
				}
			}
			_generators.push(generator);
			return generatorChanged;
		}
	}
}