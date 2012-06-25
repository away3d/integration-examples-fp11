package
{
	import starling.extensions.PDParticleSystem;
	import starling.core.Starling;
	import starling.extensions.ParticleSystem;
	import starling.textures.Texture;
	import starling.display.Sprite;

	/**
	 * @author Greg
	 */
	public class StarlingImpactEffectSprite extends Sprite
	{
		// Starling Particle assets
		[Embed(source="../embeds/explode.pex", mimeType="application/octet-stream")]
		private static const ExplodeConfig:Class;
		[Embed(source = "../embeds/explode_particle.png")]
		private static const ExplodeParticle:Class;
		private var mParticleSystem:ParticleSystem;
		private static var _instance:StarlingImpactEffectSprite;

		public static function getInstance():StarlingImpactEffectSprite
		{
			return _instance;
		}

		public function StarlingImpactEffectSprite()
		{
			_instance = this;
			
			var psConfig:XML = XML(new ExplodeConfig());
			var psTexture:Texture = Texture.fromBitmap(new ExplodeParticle());

			mParticleSystem = new PDParticleSystem(psConfig, psTexture);
			mParticleSystem.emitterX = 460;
			mParticleSystem.emitterY = 430;
			mParticleSystem.maxCapacity = 75;
			this.addChild(mParticleSystem);

			Starling.juggler.add(mParticleSystem);
		}

		public function fireUp():void
		{
			mParticleSystem.start(0.3);
		}
	}
}
