/* 
Framework Integration Example

Starling scene used in the framework integration examples.

Code by Greg Caldwell
greg@geepers.co.uk
http://www.geepers.co.uk

This code is distributed under the MIT License

Copyright (c)  

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

 */
package
{
	import starling.display.Quad;
	import starling.display.DisplayObject;
	import starling.core.Starling;
	import starling.extensions.PDParticleSystem;
	import starling.extensions.ParticleSystem;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.display.Sprite;

	public class StarlingWallSprite extends Sprite
	{
		[Embed(source = "../embeds/wall.jpg")]
		private static const WallImage:Class;
		
		[Embed(source = "../embeds/wallfire.gif")]
		private static const FireplaceImage:Class;
		
		[Embed(source = "../embeds/wallfireback.jpg")]
		private static const FireplaceBackImage:Class;
		
		// Starling Particle assets
		[Embed(source="../embeds/fire.pex", mimeType="application/octet-stream")]
		private static const FireConfig:Class;
		
		[Embed(source = "../embeds/fire_particle.png")]
		private static const FireParticle:Class;
		
		private static var _instance:StarlingWallSprite;
		
		private var mParticleSystem:ParticleSystem;
		private var wallContainer:Sprite;
		private var wallParts:Vector.<DisplayObject>;
		private var _width : Number;
		private var overlay : Quad;

		public function get wall():Sprite
		{
			return wallContainer;
		}

		public function set wall(wall:Sprite):void
		{
			wallContainer = wall;
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
			
			wallParts = new Vector.<DisplayObject>();

			wallContainer = new Sprite();
			addChild(wallContainer);

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
					wallContainer.addChild(fire);

					Starling.juggler.add(mParticleSystem);
					wallParts.push(fire);
				} else {
					var image:Image = new Image(wall);
					image.x = fX*image.width;
					image.name = "image_" + fX;

					wallContainer.addChild(image);
					wallParts.push(image);
				}
			}
			_width = wallContainer.width;
			
			overlay = new Quad(1024, 512, 0x0, false);
			wallContainer.addChild(overlay);
		}

		public function scrollWall(distance:Number):void
		{
			for each (var dO:DisplayObject in wallParts) {
				dO.x += distance;
				if (dO.x < -512) dO.x += _width;
			}
		}
		
		public function set glowIntensity(intensity:Number) : void {
			overlay.alpha = 0.6 - (intensity * 0.6);
		}
	}
}
