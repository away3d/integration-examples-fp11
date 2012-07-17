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
package starling.rootsprites
{
	import starling.extensions.PDParticleSystem;
	import starling.core.Starling;
	import starling.extensions.ParticleSystem;
	import starling.textures.Texture;
	import starling.display.Sprite;

	public class StarlingImpactEffectSprite extends Sprite
	{
		// Starling Particle assets
		[Embed(source="/../embeds/explode.pex", mimeType="application/octet-stream")]
		private static const ExplodeConfig:Class;
		[Embed(source = "/../embeds/explode_particle.png")]
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
			mParticleSystem.emitterY = 390;
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
