package
{
	import away3d.animators.*;
	import away3d.animators.data.*;
	import away3d.containers.*;
	import away3d.core.managers.*;
	import away3d.debug.*;
	import away3d.events.*;
	import away3d.entities.*;
	import away3d.library.*;
	import away3d.library.assets.*;
	import away3d.lights.*;
	import away3d.loaders.parsers.*;
	import away3d.materials.*;
	import away3d.materials.lightpickers.*;
	import away3d.materials.methods.*;
	import away3d.primitives.*;
	import away3d.textures.*;
	import away3d.utils.*;

	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;

	import starling.core.*;

	[SWF(width="800", height="600", frameRate="60")]
	public class Away3D_Starling_Layering_Demo extends Sprite
	{
		[Embed(source="../embeds/hellknight.jpg")]
		private var HellknightDiffuse:Class;
		[Embed(source="../embeds/hellknight_local.png")]
		private var HellknightNormal:Class;
		[Embed(source="../embeds/hellknight_s.png")]
		private var HellknightSpecular:Class;
		[Embed(source="../embeds/hellknight.md5mesh", mimeType="application/octet-stream")]
		private var HellknightMesh:Class;
		[Embed(source="../embeds/walk7.md5anim", mimeType="application/octet-stream")]
		private var HellknightWalkAnim:Class;
		[Embed(source="../embeds/woodfloor.jpg")]
		private var WoodFloorImage:Class;
		
		// Stage manager and Stage3D instance proxy classes
		private var stage3DManager:Stage3DManager;
		private var stage3DProxy1:Stage3DProxy;
		private var stage3DProxy2:Stage3DProxy;
		
		//Away3D engine variables
		private var away3dView1:View3D;
		private var away3dView2:View3D;
		
		//starling engine variables
		private var starlingWallScene:Starling;
		private var starlingImpactScene:Starling;
		private var starlingHUDScene:Starling;
		
		//view 1 light objects
		private var fireLightLocation:Vector3D;
		private var fireLight:DirectionalLight;
		private var fireShadowMethod:TripleFilteredShadowMapMethod;
		private var fireLightPicker:StaticLightPicker;
		
		//view 2 light objects
		private var hudLightLocation:Vector3D;
		private var hudLight:DirectionalLight;
		private var hudShadowMethod:TripleFilteredShadowMapMethod;
		private var hudLightPicker:StaticLightPicker;
		
		//Away3D material objects
		private var floorMaterial:TextureMaterial;
		private var hellKnightMaterial:TextureMaterial;
		private var sphereMaterial:TextureMaterial;
		private var cubeMaterial:TextureMaterial;
		private var ballMaterial:TextureMaterial;
		
		//Away3D scene objects
		private var hellKnightMesh:Mesh;
		private var hellKnightAnimator:SmoothSkeletonAnimator;
		private var floorPlane:Mesh;
		private var attackSphere:Mesh;
		private var sphereContainer:ObjectContainer3D;
		private var hudCube:Mesh;
		private var hudContainer1:ObjectContainer3D;
		private var hudContainer2:ObjectContainer3D;
		private var hudContainer3:ObjectContainer3D;
		
		//Starling scene objects
		private var starlingWallSprite:StarlingWallSprite;
		private var starlingImpactSprite:StarlingImpactEffectSprite;
		private var starlingHUDSprite:StarlingHUDSprite;
		
		// runtime variables
		private var sinCount:Number = 0;
		private var activeHUD:Boolean = true;
		
		
		
				
		/**
		 * Constructor
		 */
		public function Away3D_Starling_Layering_Demo()
		{
			init();
		}
		
		/**
		 * Global initialise function
		 */
		private function init():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			initProxies();
			initAway3D();
			initStarling();
			//initText();
			initLights();
			initMaterials();
			initObjects();
			initListeners();
		}
		
		/**
		 * Initialise the Stage3D proxies
		 */
		private function initProxies():void
		{
			// Define a new Stage3DManager for the Stage3D objects
			stage3DManager = Stage3DManager.getInstance(stage);

			// Create a new Stage3D proxy for the first Stage3D object
			stage3DProxy1 = stage3DManager.getFreeStage3DProxy();
			stage3DProxy1.color = 0x66aa00;

			// Create a new Stage3D proxy for the second Stage3D object
			stage3DProxy2 = stage3DManager.getFreeStage3DProxy();
			stage3DProxy2.color = 0x000000;
			stage3DProxy2.y = 5;
			stage3DProxy2.width = 256;
			stage3DProxy2.height = 256;
		}
		
		/**
		 * Initialise the Away3D scenes
		 */
		private function initAway3D():void
		{
			// Create the first Away3D view which holds the monster and the flying ball object.
			away3dView1 = new View3D();
			away3dView1.camera.z = -300;
			away3dView1.stage3DProxy = stage3DProxy1;
			away3dView1.shareContext = true;
			
			addChild(away3dView1);
			
			addChild(new AwayStats(away3dView1));
			
			//Create the second Away3D view which holds the spinning cubes
			away3dView2 = new View3D();
			away3dView2.stage3DProxy = stage3DProxy2;
			away3dView2.shareContext = true;
			
			addChild(away3dView2);
		}
				
		/**
		 * Initialise the Starling scenes
		 */
		private function initStarling():void
		{
		
			//Create the Starling scene to add the background wall/fireplace. This is positioned on top of the floor scene starting at the top of the screen. It slightly covers the wooden floor layer to avoid any gaps appearing.
			starlingWallScene = new Starling(StarlingWallSprite, stage, stage3DProxy1.viewPort, stage3DProxy1.stage3D);
			starlingWallScene.shareContext = true;
			
			// Create the Starling scene that shows the foreground ball impact particle effect. This appears in front of all the other layers.
			starlingImpactScene = new Starling(StarlingImpactEffectSprite, stage, stage3DProxy1.viewPort, stage3DProxy1.stage3D);
			starlingImpactScene.shareContext = true;
			
		 	//Create the Starling scene that shows the foreground ball impact particle effect. This appears in front of all the other layers.
			starlingHUDScene = new Starling(StarlingHUDSprite, stage, stage3DProxy2.viewPort, stage3DProxy2.stage3D);
			starlingHUDScene.shareContext = true;
		}
		
		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			// Create the fire light
			fireLightLocation = new Vector3D(-65.5, -30, -10);
			fireLight = new DirectionalLight();
			fireLight.ambient = 0.25;
			fireLight.ambientColor = 0xa0a0a0;
			fireLight.color = 0xffa020;
			fireLight.castsShadows = true;
			fireLight.direction = fireLightLocation;
			
			//add the fire light to the monster Away3D scene
			away3dView1.scene.addChild(fireLight);
			
			//create the fire light shadow method
			fireShadowMethod = new TripleFilteredShadowMapMethod(fireLight);
			
			//create the light picker for the fire light
			fireLightPicker = new StaticLightPicker([fireLight]);
			
			//create the hud light
			hudLightLocation = new Vector3D(-465.5, -130, 200);
			hudLight = new DirectionalLight();
			hudLight.ambient = 2;
			hudLight.ambientColor = 0xa0a0a0;
			hudLight.color = 0xfffff;
			hudLight.castsShadows = true;
			hudLight.direction = hudLightLocation;
			
			//add the hud light to the HUD Away3D scene
			away3dView2.scene.addChild(hudLight);
			
			//create the hud light shadow method
			hudShadowMethod = new TripleFilteredShadowMapMethod(hudLight);
			
			//create the light picker for the hud light
			hudLightPicker = new StaticLightPicker([hudLight]);
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			// Create a material for the floor
			floorMaterial = new TextureMaterial(Cast.bitmapTexture(WoodFloorImage));
			floorMaterial.ambient = 2.5;
			floorMaterial.lightPicker = fireLightPicker;
			floorMaterial.normalMap = new BitmapTexture(new BitmapData(128, 128, false, 0xff807fff));
			floorMaterial.specularMap = new BitmapTexture(new BitmapData(128, 128, false, 0xffffffff));
			floorMaterial.repeat = true;
			floorMaterial.shadowMethod = fireShadowMethod;

			// Create a material for the monster
			hellKnightMaterial = new TextureMaterial(Cast.bitmapTexture(HellknightDiffuse));
			hellKnightMaterial.gloss = 20;
			hellKnightMaterial.ambientColor = 0x505060;
			hellKnightMaterial.ambient = 5;
			hellKnightMaterial.specular = 1.3;
			hellKnightMaterial.normalMap = Cast.bitmapTexture(HellknightNormal);
			hellKnightMaterial.specularMap = Cast.bitmapTexture(HellknightSpecular);
			hellKnightMaterial.lightPicker = fireLightPicker;
			hellKnightMaterial.shadowMethod = fireShadowMethod;
			
			// Create a material for the sphere
			sphereMaterial = new TextureMaterial(new BitmapTexture(new BitmapData(16, 16, false, 0x80c0ff)));
			sphereMaterial.ambient = 1;
			sphereMaterial.ambientColor = 0x909090;
			sphereMaterial.lightPicker = fireLightPicker;
			
			//Create a material for the cube
			var bmd:BitmapData = new BitmapData(128, 128, false, 0x0);
			bmd.perlinNoise(7, 7, 5, 12345, true, true);
			cubeMaterial = new TextureMaterial(new BitmapTexture(bmd));
			cubeMaterial.gloss = 20;
			cubeMaterial.ambientColor = 0x808080;
			cubeMaterial.ambient = 1;
			cubeMaterial.lightPicker = hudLightPicker;
			cubeMaterial.shadowMethod = hudShadowMethod;
			
			// Create a material for the HUD balls
			var red:BitmapData = new BitmapData(128, 128, false, 0x0000ff);
			ballMaterial = new TextureMaterial(new BitmapTexture(red));
			ballMaterial.gloss = 50;
			ballMaterial.ambientColor = 0xffffff;
			ballMaterial.ambient = 10;
			ballMaterial.lightPicker = hudLightPicker;
			ballMaterial.shadowMethod = hudShadowMethod;

		}
		
		/**
		 * Initialise the Away3D scene objects
		 */
		private function initObjects():void
		{
			// Build the floor plane, assign the material, position it and scale it's texturing
			floorPlane = new Mesh(new PlaneGeometry(2000, 150), floorMaterial);
			floorPlane.y = -150;
			floorPlane.geometry.scaleUV(20, 1);
			away3dView1.scene.addChild(floorPlane);
			
			//build the attack sphere
			attackSphere = new Mesh(new SphereGeometry(15), sphereMaterial);
			attackSphere.x = 600;
			attackSphere.y = -80;
			
			// Build a container for the ball animation
			sphereContainer = new ObjectContainer3D();
			sphereContainer.addChild(attackSphere);
			away3dView1.scene.addChild(sphereContainer);
			
			// Load the monster mesh
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.loadData(new HellknightMesh(), null, null, new MD5MeshParser());
			
			// Build the HUD cube
			hudCube = new Mesh(new CubeGeometry(400, 400, 400), cubeMaterial);
			away3dView2.scene.addChild(hudCube);
			
			//build the HUD balls
			var s:Mesh;
			
			s = new Mesh(new SphereGeometry(35), ballMaterial);
			s.x = 350;
			hudContainer1 = new ObjectContainer3D();
			hudContainer1.addChild(s);
			away3dView2.scene.addChild(hudContainer1);

			s = new Mesh(new SphereGeometry(35), ballMaterial);
			s.y = 350;
			hudContainer2 = new ObjectContainer3D();
			hudContainer2.addChild(s);
			away3dView2.scene.addChild(hudContainer2);

			s = new Mesh(new SphereGeometry(35), ballMaterial);
			s.z = 350;
			hudContainer3 = new ObjectContainer3D();
			hudContainer3.addChild(s);
			away3dView2.scene.addChild(hudContainer3);
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			// Mouse click listener to manage HUD rendering toggle
			stage.addEventListener(MouseEvent.CLICK, onClick);
			
			// Enter frame listener to manage monster Stage3D rendering
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			// Enter frame listener to manage HUD Stage3D rendering
			stage3DProxy2.addEventListener(Event.ENTER_FRAME, onEnterFrameStage3DProxy);
			
			// Resize listener to handle stage resize
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		/* 
		 * Process the asset loading for the monster mesh and animations
		 */
		private function onAssetComplete(event:AssetEvent):void
		{
			if (event.asset.assetType == AssetType.ANIMATION) {
				var seq:SkeletonAnimationSequence = event.asset as SkeletonAnimationSequence;
				seq.name = event.asset.assetNamespace;
				seq.looping = true;
				hellKnightAnimator = new SmoothSkeletonAnimator(hellKnightMesh.animationState as SkeletonAnimationState);
				hellKnightAnimator.addSequence(seq);

				hellKnightAnimator.play("walk7");
			} else if (event.asset.assetType == AssetType.MESH) {
				hellKnightMesh = event.asset as Mesh;
				hellKnightMesh.material = hellKnightMaterial;
				hellKnightMesh.y = -150;
				hellKnightMesh.rotationY = -90;
				away3dView1.scene.addChild(hellKnightMesh);

				AssetLibrary.loadData(new HellknightWalkAnim(), null, "walk7", new MD5AnimParser());
			}
		}
		
		/**
		 * Render loop for monster Stage3D proxy
		 */
		private function onEnterFrame(event:Event):void
		{
			// Update the direction of the light to approximately coincide with the position of the fireplace (Starling scene)
			fireLightLocation.x += 0.2;
			
			//wrap light direction if fireplace moved on too far
			if (fireLightLocation.x > 45)
				fireLightLocation.x = -65;
			
			//apply light direction to Away3D light object
			fireLight.direction = fireLightLocation.add(new Vector3D(Math.random(), Math.random(), Math.random()));
			
			// Vary the intensity of the light based on the position of the light in the scene;
			var intensity:Number = 1 - Math.abs(2*((fireLightLocation.x + 5)/110));
			fireLight.diffuse = fireLight.specular = intensity;
			
			// Vary the ambient value of the monster based on the light position
			hellKnightMaterial.ambient = 7.5 + (intensity*3);
			
			// Move the scene objects in line with the monster.
			if (hellKnightMesh)
				away3dView1.camera.x = sphereContainer.x = hellKnightMesh.x;
			
			// (Away3D) Reposition the Wooden floor
			if (away3dView1.camera.x > floorPlane.x + 500)
				floorPlane.x += 1000;
			
			// Scroll the background Starling wall
			starlingWallSprite = StarlingWallSprite.getInstance();
			if (starlingWallSprite)
				starlingWallSprite.scrollWall(-2.75);
			
			// Update the attack sphere
			attackSphere.x -= 10;
			if (attackSphere.x <= 40) {
				attackSphere.x = 300;
				starlingImpactSprite = StarlingImpactEffectSprite.getInstance();
				if (starlingImpactSprite)
					starlingImpactSprite.fireUp();
			}
			
			// Clear the Context3D object
			stage3DProxy1.clear();
			
			// Render the background Starling layer
			starlingWallScene.nextFrame();
			
			// Render the intermediate Away3D layer
			away3dView1.render();
			
			// Render the foreground Starling layer
			starlingImpactScene.nextFrame();
			
			// Present the Context3D object to Stage3D
			stage3DProxy1.present();
		}
		
		/**
		 * Render loop for HUD Stage3D proxy
		 */
		private function onEnterFrameStage3DProxy(event:Event):void
		{
			// Update the Away3D HUD background (3D cube)
			hudCube.rotationX += 1.1;
			hudCube.rotationY += 2.19;
			hudCube.rotationZ += 1.37;

			hudContainer1.rotationX -= 2.75;
			hudContainer1.rotationY += 4.38;
			hudContainer1.rotationZ -= 3.12;

			hudContainer2.rotationX += 4.8;
			hudContainer2.rotationY -= 3.1;
			hudContainer2.rotationZ -= 1.6;

			hudContainer3.rotationX += 2.5;
			hudContainer3.rotationY -= 1.1;
			hudContainer3.rotationZ += 4.6;
			
			//render the backgroud Away3D layer
			away3dView2.render();
			
			//update the Starling HUD foreground (2D scrolling text)
			starlingHUDSprite = StarlingHUDSprite.getInstance();
			if (starlingHUDSprite)
				starlingHUDSprite.updateScene();
			
			//render the foreground Starling layer
			starlingHUDScene.nextFrame();
			
			//update the HUD position
			stage3DProxy2.x = 340 + 200*Math.sin(0.04*sinCount++);
		}
		
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			// Scale monster Stage3D proxy to maintain aspect ratio but fill stage width
			stage3DProxy1.width = stage.stageWidth;
			stage3DProxy1.height = 600*stage.stageWidth/800;
		}
		
		/**
		 * mouse listener for click events
		 */
		private function onClick(event:MouseEvent):void
		{
			activeHUD = !activeHUD;
			
			//toggle enterframe listener of HUD Stage3D proxy
			if (activeHUD) 
				stage3DProxy2.addEventListener(Event.ENTER_FRAME, onEnterFrameStage3DProxy);
			else
				stage3DProxy2.removeEventListener(Event.ENTER_FRAME, onEnterFrameStage3DProxy);
		}
	}
}
