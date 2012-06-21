package {
	import flash.geom.Rectangle;

	import starling.extensions.ClippedSprite;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.events.Event;
	import starling.display.Sprite;

	/**
	 * @author Greg
	 */
	public class StarlingHUDScene extends Sprite {
		[Embed(source = "../assets/hud.png")]
		private static const HUDImage : Class;
		[Embed(source = "../assets/text.gif")]
		private static const TextImage : Class;
		[Embed(source = "../assets/inner.png")]
		private static const InnerImage : Class;
		[Embed(source = "../assets/outer.png")]
		private static const OuterImage : Class;
		private static var _instance : StarlingHUDScene;
		private var _text : ClippedSprite;
		private var _inner : Sprite;
		private var _outer : Sprite;

		public static function getInstance() : StarlingHUDScene {
			return _instance;
		}

		public function StarlingHUDScene() {
			_instance = this;
			this.addEventListener(Event.ADDED_TO_STAGE, initScene);
		}

		private function initScene(event : Event) : void {
			this.removeEventListener(Event.ADDED_TO_STAGE, initScene);

			var hud : Texture = Texture.fromBitmap(new HUDImage());
			var text : Texture = Texture.fromBitmap(new TextImage());

			addChild(new Image(hud));

			_text = new ClippedSprite();
			_text.addChild(new Image(text));

			var textContainer : ClippedSprite = new ClippedSprite();
			textContainer.x = textContainer.y = 0;
			textContainer.clipRect = new Rectangle(0, 10, 236, 236);
			textContainer.addChild(_text);
			addChild(textContainer);

			var inner : Texture = Texture.fromBitmap(new InnerImage());
			_inner = new Sprite();
			_inner.x = _inner.y = _inner.pivotX = _inner.pivotY = 128;
			_inner.addChild(new Image(inner));
			addChild(_inner);

			var outer : Texture = Texture.fromBitmap(new OuterImage());
			_outer = new Sprite();
			_outer.x = _outer.y = _outer.pivotX = _outer.pivotY = 128;
			_outer.addChild(new Image(outer));
			addChild(_outer);
		}

		public function updateScene() : void {
			// Scroll the text
			_text.y -= 10;
			if (_text.y < -768) _text.y = 0;

			// Rotate the HUD components
			_inner.rotation += 0.05;
			_outer.rotation -= 0.05;
		}
	}
}
