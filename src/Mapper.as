package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.Sprite;
	import flash.filters.ShaderFilter;
	
	/**
	 * auto Mapper v0.2 ~ Lo.th 2012
	 * Pixel bender filter: Jan-C.F, S.Kimura
	 */
	
	public class Mapper extends Sprite
	{
		[Embed(source="../pb/sharpen.pbj", mimeType="application/octet-stream")]
		private var BumpClass:Class;
		[Embed(source="../pb/NormalMap.pbj", mimeType="application/octet-stream")]
		private var NormalClass:Class;
		[Embed(source="../pb/Outline.pbj", mimeType="application/octet-stream")]
		private var LumaClass:Class;
		
		private var _shaders:Vector.<Shader>;
		private var _bitmap:Vector.<Bitmap>;
		private var _bitdata:Vector.<BitmapData>;
		
		public function Mapper(origineMap:BitmapData = null)
		{
			_shaders = new Vector.<Shader>();
			_bitmap = new Vector.<Bitmap>();
			_bitdata = new Vector.<BitmapData>();
			_bitmap.push(
				new Bitmap(origineMap),
				new Bitmap(origineMap),
				new Bitmap(origineMap)
			);
			_shaders.push(
				new Shader(new BumpClass()),
				new Shader(new NormalClass()),
				new Shader(new LumaClass())
			);
			applyFilters();
		}
		
		// ======================================================================
		//	aplly filters
		// ----------------------------------------------------------------------
		private function applyFilters():void
		{
			// Bump
			_shaders[0].data.amount.value = [5];
			_shaders[0].data.radius.value = [.2];
			_bitmap[0].filters = [new ShaderFilter(_shaders[0])];
			// Normal
			_shaders[1].data.amount.value = [4];//0 to 5
			_shaders[1].data.soft_sobel.value = [1];//int 0 or 1
			_shaders[1].data.invert_red.value = [1];//-1 to 1
			_shaders[1].data.invert_green.value = [1];//-1 to 1
			_bitmap[1].filters = [new ShaderFilter(_shaders[1])];
			// Speculare
			/*_shaders[2].data.difference.value = [1,0.15];
			_shaders[2].data.color.value = [1,1,1,1];
			_shaders[2].data.bgcolor.value = [0, 0, 0, 1];
			*/
			_shaders[2].data.difference.value = [0, 1];
			_shaders[2].data.color.value = [1, 1, 1, 1];
			_shaders[2].data.bgcolor.value = [0.2, 0.2, 0.2, 1];
			_bitmap[2].filters = [new ShaderFilter(_shaders[2])];
			
			_bitdata.push(
				bit(_bitmap[0]),
				bit(_bitmap[1]),
				bit(_bitmap[2])
			);
		}
		
		private function bit(B:Bitmap):BitmapData
		{
			var b:BitmapData = new BitmapData(B.width, B.height, true);
			b.draw(B);
			return b;
		}
		
		
		// ======================================================================
		//	bitmap result
		// ----------------------------------------------------------------------
		public function get bitdata():Vector.<BitmapData> { return _bitdata; }
		
		public function set bitdata(a:Vector.<BitmapData>):void { _bitdata = a; }
	}
}