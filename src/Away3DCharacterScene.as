package {
	import flash.geom.Vector3D;

	import away3d.loaders.parsers.MD5AnimParser;
	import away3d.primitives.SphereGeometry;
	import away3d.animators.SmoothSkeletonAnimator;
	import away3d.animators.data.SkeletonAnimationState;
	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.library.assets.AssetType;
	import away3d.containers.ObjectContainer3D;
	import away3d.loaders.parsers.MD5MeshParser;
	import away3d.events.AssetEvent;
	import away3d.library.AssetLibrary;
	import away3d.primitives.PlaneGeometry;
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
	public class Away3DCharacterScene extends View3D {
		[Embed(source="../assets/hellknight.jpg")]
		private var HellknightDiffuse : Class;
		[Embed(source="../assets/hellknight_local.png")]
		private var HellknightNormal : Class;
		[Embed(source="../assets/hellknight_s.png")]
		private var HellknightSpecular : Class;
		[Embed(source="../assets/hellknight.md5mesh", mimeType="application/octet-stream")]
		private var HellknightMesh : Class;
		[Embed(source="../assets/walk7.md5anim", mimeType="application/octet-stream")]
		private var HellknightWalkAnim : Class;
		[Embed(source="../assets/woodfloor.jpg")]
		private var WoodFloorImage : Class;
		private var _fireLight : DirectionalLight;
		private var _shadowMapMethod : TripleFilteredShadowMapMethod;
		private var _lightPicker : StaticLightPicker;
		private var _sphereContainer : ObjectContainer3D;
		private var _sphere : Mesh;
		private var _hellknight : Mesh;
		private var _hellknightMaterial : TextureMaterial;
		private var _animator : SmoothSkeletonAnimator;
		private var _fireLocation : Vector3D;
		private var _woodenFloor : Mesh;
		private var _floorOffset : Number;

		/*
		 * The texture offset for the wooden floor scrolling
		 */
		public function get floorOffset() : Number {
			return _floorOffset;
		}

		public function set floorOffset(floorOffset : Number) : void {
			// Update the floor texture scrolling offset and apply it to the floor mesh.
			_floorOffset = floorOffset;
			_woodenFloor.subMeshes[0].offsetU = _floorOffset;
		}

		/*
		 * The sphere object container
		 */
		public function get sphere() : Mesh {
			return _sphere;
		}

		public function set sphere(sphere : Mesh) : void {
			_sphere = sphere;
		}

		public function Away3DCharacterScene() {
			super();

			_camera.z = -300;

			// Create the fire light
			_fireLocation = new Vector3D(-65.5, -30, -10);
			_fireLight = new DirectionalLight();
			_fireLight.ambient = 0.25;
			_fireLight.ambientColor = 0xa0a0a0;
			_fireLight.color = 0xffa020;
			_fireLight.castsShadows = true;
			_fireLight.direction = _fireLocation;

			_shadowMapMethod = new TripleFilteredShadowMapMethod(_fireLight);
			_lightPicker = new StaticLightPicker([_fireLight]);

			// Create a floor texture to receive the shadow
			var floorMat : TextureMaterial = new TextureMaterial(new BitmapTexture(new WoodFloorImage()["bitmapData"]));
			floorMat.ambient = 2.5;
			floorMat.lightPicker = _lightPicker;
			floorMat.normalMap = new BitmapTexture(new BitmapData(128, 128, false, 0xff807fff));
			floorMat.specularMap = new BitmapTexture(new BitmapData(128, 128, false, 0xffffffff));
			floorMat.repeat = true;
			// floorMat.animateUVs = true;    			// ##### Offending line that disables shadows when true
			floorMat.shadowMethod = _shadowMapMethod;

			// Build the floor plane, assign the material, position it and scale it's texturing
			var pG : PlaneGeometry = new PlaneGeometry(1000, 150);
			_woodenFloor = new Mesh(pG, floorMat);
			_woodenFloor.y = -150;
			_woodenFloor.geometry.scaleUV(10, 1);

			this.scene.addChild(_woodenFloor);

			_floorOffset = 0;

			// Create the texture for the monster
			_hellknightMaterial = new TextureMaterial(new BitmapTexture(new HellknightDiffuse()['bitmapData']));
			_hellknightMaterial.gloss = 20;
			_hellknightMaterial.ambientColor = 0x505060;
			_hellknightMaterial.ambient = 5;
			_hellknightMaterial.specular = 1.3;
			_hellknightMaterial.normalMap = new BitmapTexture(new HellknightNormal()['bitmapData']);
			_hellknightMaterial.specularMap = new BitmapTexture(new HellknightSpecular()['bitmapData']);
			_hellknightMaterial.lightPicker = _lightPicker;
			_hellknightMaterial.shadowMethod = _shadowMapMethod;

			// Load the monster mesh
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.loadData(new HellknightMesh(), null, null, new MD5MeshParser());

			// Build a container for the ball animation
			_sphereContainer = new ObjectContainer3D();

			// Create a texture for the ball
			var sphereMat : TextureMaterial = new TextureMaterial(new BitmapTexture(new BitmapData(16, 16, false, 0x80c0ff)));
			sphereMat.ambient = 1;
			sphereMat.ambientColor = 0x909090;
			sphereMat.lightPicker = _lightPicker;
			_sphere = new Mesh(new SphereGeometry(15), sphereMat);
			_sphere.x = 600;
			_sphere.y = -80;
			_sphereContainer.addChild(_sphere);

			// Add the objects to the scene
			this.scene.addChild(_fireLight);
			this.scene.addChild(_woodenFloor);
			this.scene.addChild(_sphereContainer);
		}

		/* 
		 * Process the asset loading for the monster mesh and animations
		 */
		private function onAssetComplete(event : AssetEvent) : void {
			if (event.asset.assetType == AssetType.ANIMATION) {
				var seq : SkeletonAnimationSequence = event.asset as SkeletonAnimationSequence;
				seq.name = event.asset.assetNamespace;
				seq.looping = true;
				_animator = new SmoothSkeletonAnimator(_hellknight.animationState as SkeletonAnimationState);
				_animator.addSequence(seq);

				_animator.play("walk7");
			} else if (event.asset.assetType == AssetType.MESH) {
				_hellknight = event.asset as Mesh;
				_hellknight.material = _hellknightMaterial;
				_hellknight.y = -150;
				_hellknight.rotationY = -90;
				this.scene.addChild(_hellknight);

				AssetLibrary.loadData(new HellknightWalkAnim(), null, "walk7", new MD5AnimParser());
			}
		}

		/*
		 * Update method called in the Enter_Frame to update the objects.
		 * The camera, shadow floor and sphereContainer are positioned in line with the 
		 * animated monster.
		 */
		public function updateScene() : void {
			// Update the direction of the light to approximately coincide with the position of
			// the fireplace (Starling scene)
			_fireLocation.x += 0.4;
			if (_fireLocation.x > 45) _fireLocation.x = -65;
			_fireLight.direction = _fireLocation.add(new Vector3D(Math.random(), Math.random(), Math.random()));

			// Vary the intensity of the light based on the position of the light in the scene;
			var intensity : Number = 1 - Math.abs(2 * ((_fireLocation.x + 5) / 110));
			_fireLight.diffuse = _fireLight.specular = intensity;

			// Vary the ambient value of the monster based on the light position
			_hellknightMaterial.ambient = 7.5 + (intensity * 3);

			// Move the scene objects in line with the monster.
			if (_hellknight) {
				this.camera.x = _woodenFloor.x = _sphereContainer.x = _hellknight.x;
			}
		}
	}
}
