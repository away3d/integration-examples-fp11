package
{
	import flash.geom.Rectangle;

	import starling.extensions.ClippedSprite;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.display.Sprite;

	/**
	 * @author Greg
	 */
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
