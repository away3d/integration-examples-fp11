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
starling.rootsprites{
	import flash.geom.Rectangle;

	import starling.extensions.ClippedSprite;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.display.Sprite;

	public class StarlingHUDSprite extends Sprite
	{
		[Embed(source = "../embeds/hud.png")]
		private static const HUDImage:Class;
		[Embed(source = "../embeds/text.gif")]
		private static const TextImage:Class;
		[Embed(source = "../embeds/inner.png")]
		private static const InnerImage:Class;
		[Embed(source = "../embeds/outer.png")]
		private static const OuterImage:Class;
		private static var _instance:StarlingHUDSprite;
		private var _text:ClippedSprite;
		private var _inner:Sprite;
		private var _outer:Sprite;

		public static function getInstance():StarlingHUDSprite
		{
			return _instance;
		}

		public function StarlingHUDSprite()
		{
			_instance = this;
			
			var hud:Texture = Texture.fromBitmap(new HUDImage());
			var text:Texture = Texture.fromBitmap(new TextImage());

			addChild(new Image(hud));

			_text = new ClippedSprite();
			_text.addChild(new Image(text));

			var textContainer:ClippedSprite = new ClippedSprite();
			textContainer.x = textContainer.y = 0;
			textContainer.clipRect = new Rectangle(0, 10, 236, 236);
			textContainer.addChild(_text);
			addChild(textContainer);

			var inner:Texture = Texture.fromBitmap(new InnerImage());
			_inner = new Sprite();
			_inner.x = _inner.y = _inner.pivotX = _inner.pivotY = 128;
			_inner.addChild(new Image(inner));
			addChild(_inner);

			var outer:Texture = Texture.fromBitmap(new OuterImage());
			_outer = new Sprite();
			_outer.x = _outer.y = _outer.pivotX = _outer.pivotY = 128;
			_outer.addChild(new Image(outer));
			addChild(_outer);
		}

		public function updateScene():void
		{
			// Scroll the text
			_text.y -= 10;
			if (_text.y < -768) _text.y = 0;

			// Rotate the HUD components
			_inner.rotation += 0.05;
			_outer.rotation -= 0.05;
		}
	}
}
