package
{
	import starling.display.DisplayObject;
	import starling.core.Starling;
	import starling.extensions.PDParticleSystem;
	import starling.extensions.ParticleSystem;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.events.Event;
	import starling.display.Sprite;

	/**
	 * @author Greg
	 */
	public class StarlingWallSprite extends Sprite
	{
		[Embed(source = "../assets/wall.jpg")]
		private static const WallImage:Class;
		[Embed(source = "../assets/wallfire.gif")]
		private static const FireplaceImage:Class;
		[Embed(source = "../assets/wallfireback.jpg")]
		private static const FireplaceBackImage:Class;
		// Starling Particle assets
		[Embed(source="../assets/fire.pex", mimeType="application/octet-stream")]
		private static const FireConfig:Class;
		[Embed(source = "../assets/fire_particle.png")]
		private static const FireParticle:Class;
		private var mParticleSystem:ParticleSystem;
		private static var _instance:StarlingWallSprite;
		private var _wall:Sprite;
		private var _wallparts:Vector.<DisplayObject>;
		private var _width:Number;

		public function get wall():Sprite
		{
			return _wall;
		}

		public function set wall(wall:Sprite):void
		{
			_wall = wall;
		}

		public static function getInstance():StarlingWallSprite
		{
			return _instance;
		}

		public function StarlingWallSprite()
		{
			_instance = this;
			
			var wall:Texture = Texture.fromBitmap(new WallImage());
			var fireplace:Texture = Texture.fromBitmap(new FireplaceImage());
			var fireplaceBack:Texture = Texture.fromBitmap(new FireplaceBackImage());

			_wallparts = new Vector.<DisplayObject>();

			_wall = new Sprite();
			addChild(_wall);

			for (var fX:int = 0; fX < 3; fX++) {
				if (fX == 2) {
					var fire:Sprite = new Sprite();
					fire.addChild(new Image(fireplaceBack));

					var psConfig:XML = XML(new FireConfig());
					var psTexture:Texture = Texture.fromBitmap(new FireParticle());

					mParticleSystem = new PDParticleSystem(psConfig, psTexture);
					mParticleSystem.emitterX = 256;
					mParticleSystem.emitterY = 490;
					mParticleSystem.maxCapacity = 500;
					mParticleSystem.start();

					fire.addChild(mParticleSystem);
					fire.addChild(new Image(fireplace));
					fire.x = fX*image.width;
					fire.name = "fire";
					_wall.addChild(fire);

					Starling.juggler.add(mParticleSystem);
					_wallparts.push(fire);
				} else {
					var image:Image = new Image(wall);
					image.x = fX*image.width;
					image.name = "image_" + fX;

					_wall.addChild(image);
					_wallparts.push(image);
				}
			}
			_width = _wall.width;
		}

		public function scrollWall(distance:Number):void
		{
			for each (var dO:DisplayObject in _wallparts) {
				dO.x += distance;
				if (dO.x < -512) dO.x += _width;
			}
		}
	}
}
