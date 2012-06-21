package starling.extensions {
	import flash.display3D.Context3D;
	import flash.geom.Rectangle;

	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.errors.MissingContextError;

	public class ClippedSprite extends Sprite {
		private var mClipRect : Rectangle;

		public override function render(support : RenderSupport, alpha : Number) : void {
			if (mClipRect == null) super.render(support, alpha);
			else {
				var context : Context3D = Starling.context;
				if (context == null) throw new MissingContextError();

				support.finishQuadBatch();
				context.setScissorRectangle(mClipRect);

				super.render(support, alpha);

				support.finishQuadBatch();
				context.setScissorRectangle(null);
			}
		}

		public function get clipRect() : Rectangle {
			var scale : Number = Starling.current.contentScaleFactor;
			return new Rectangle(mClipRect.x / scale, mClipRect.y / scale, mClipRect.width / scale, mClipRect.height / scale);
		}

		public function set clipRect(value : Rectangle) : void {
			var scale : Number = Starling.current.contentScaleFactor;
			if (mClipRect == null) mClipRect = new Rectangle();
			mClipRect.x = scale * value.x;
			mClipRect.y = scale * value.y;
			mClipRect.width = scale * value.width;
			mClipRect.height = scale * value.height;
		}
	}
}