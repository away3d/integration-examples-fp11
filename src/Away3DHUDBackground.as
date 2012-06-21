package {
	import away3d.primitives.SphereGeometry;
	import away3d.containers.ObjectContainer3D;
	import away3d.primitives.CubeGeometry;

	import flash.geom.Vector3D;

	import away3d.entities.Mesh;

	import flash.display.BitmapData;

	import away3d.textures.BitmapTexture;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.TripleFilteredShadowMapMethod;
	import away3d.lights.DirectionalLight;
	import away3d.containers.View3D;

	/**
	 * @author Greg
	 */
	public class Away3DHUDBackground extends View3D {
		private var _lightLocation : Vector3D;
		private var _light : DirectionalLight;
		private var _shadowMapMethod : TripleFilteredShadowMapMethod;
		private var _lightPicker : StaticLightPicker;
		private var _cube : Mesh;
		private var _bC1 : ObjectContainer3D;
		private var _bC2 : ObjectContainer3D;
		private var _bC3 : ObjectContainer3D;

		public function Away3DHUDBackground() {
			super();

			this.antiAlias = 8;

			// Create the fire light
			_lightLocation = new Vector3D(-465.5, -130, 200);
			_light = new DirectionalLight();
			_light.ambient = 2;
			_light.ambientColor = 0xa0a0a0;
			_light.color = 0xfffff;
			_light.castsShadows = true;
			_light.direction = _lightLocation;

			_shadowMapMethod = new TripleFilteredShadowMapMethod(_light);
			_lightPicker = new StaticLightPicker([_light]);

			var bmd : BitmapData = new BitmapData(128, 128, false, 0x0);
			bmd.perlinNoise(7, 7, 5, 12345, true, true);
			var cubeMat : TextureMaterial = new TextureMaterial(new BitmapTexture(bmd));
			cubeMat.gloss = 20;
			cubeMat.ambientColor = 0x808080;
			cubeMat.ambient = 1;
			cubeMat.lightPicker = _lightPicker;
			cubeMat.shadowMethod = _shadowMapMethod;

			_cube = new Mesh(new CubeGeometry(400, 400, 400), cubeMat);

			var red : BitmapData = new BitmapData(128, 128, false, 0x0000ff);
			var ballMat : TextureMaterial = new TextureMaterial(new BitmapTexture(red));
			ballMat.gloss = 50;
			ballMat.ambientColor = 0xffffff;
			ballMat.ambient = 10;
			ballMat.lightPicker = _lightPicker;
			ballMat.shadowMethod = _shadowMapMethod;

			var s : Mesh;
			s = new Mesh(new SphereGeometry(35), ballMat);
			s.x = 350;
			_bC1 = new ObjectContainer3D();
			_bC1.addChild(s);

			s = new Mesh(new SphereGeometry(35), ballMat);
			s.y = 350;
			_bC2 = new ObjectContainer3D();
			_bC2.addChild(s);

			s = new Mesh(new SphereGeometry(35), ballMat);
			s.z = 350;
			_bC3 = new ObjectContainer3D();
			_bC3.addChild(s);

			// Add the objects to the scene
			this.scene.addChild(_light);
			this.scene.addChild(_cube);
			this.scene.addChild(_bC1);
			this.scene.addChild(_bC2);
			this.scene.addChild(_bC3);
		}

		/*
		 * Update method called in the Enter_Frame to update the objects.
		 * The camera, shadow floor and sphereContainer are positioned in line with the 
		 * animated monster.
		 */
		public function updateScene() : void {
			_cube.rotationX += 1.1;
			_cube.rotationY += 2.19;
			_cube.rotationZ += 1.37;

			_bC1.rotationX -= 2.75;
			_bC1.rotationY += 4.38;
			_bC1.rotationZ -= 3.12;

			_bC2.rotationX += 4.8;
			_bC2.rotationY -= 3.1;
			_bC2.rotationZ -= 1.6;

			_bC3.rotationX += 2.5;
			_bC3.rotationY -= 1.1;
			_bC3.rotationZ += 4.6;
		}
	}
}
