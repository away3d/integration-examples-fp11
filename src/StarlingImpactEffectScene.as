package {
	import starling.extensions.PDParticleSystem;
	import starling.core.Starling;
	import starling.extensions.ParticleSystem;
	import starling.textures.Texture;
	import starling.events.Event;
	import starling.display.Sprite;

	/**
	 * @author Greg
	 */
	public class StarlingImpactEffectScene extends Sprite {
		// Starling Particle assets
        [Embed(source="../assets/explode.pex", mimeType="application/octet-stream")]
        private static const ExplodeConfig:Class;

        [Embed(source = "../assets/explode_particle.png")]
        private static const ExplodeParticle:Class;
        	
        private var mParticleSystem:ParticleSystem;

		private static var _instance : StarlingImpactEffectScene;

		public static function getInstance():StarlingImpactEffectScene { return _instance; }
		
		public function StarlingImpactEffectScene() {
			_instance = this;
			this.addEventListener(Event.ADDED_TO_STAGE, initScene);
		}

		private function initScene(event : Event) : void {
			this.removeEventListener(Event.ADDED_TO_STAGE, initScene);

			var psConfig:XML = XML(new ExplodeConfig());
            var psTexture:Texture = Texture.fromBitmap(new ExplodeParticle()); 
            
            mParticleSystem = new PDParticleSystem(psConfig, psTexture);
            mParticleSystem.emitterX = (stage.stageWidth / 2) + 60;
            mParticleSystem.emitterY = 430;
			mParticleSystem.maxCapacity = 75;
			this.addChild(mParticleSystem);

			Starling.juggler.add(mParticleSystem);			
		}
		
		public function fireUp() : void {
			mParticleSystem.start(0.3);
		}
	}
}
