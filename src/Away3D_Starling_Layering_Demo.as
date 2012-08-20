/* 
Framework Integration Example

Demonstrates :

An advanced example of multiple frameworks being layered on separate stage3d/context3d 
instances via the Stage3DProxy class. The first stage3d instance is a scrolling 
wall using the Starling framework with a particle based fire. Layered on top of this is 
an Away3D View3D instance containing an animated MD5 model casting a shadow onto a floor 
plane. Also in the same View3D a sphere continually impacts the MD5 model which triggers
a particle effect in a secondary Starling layer on top of the View3D layer. 

The second stage3d instance is on top of the first and is a HUD like display. It has 
a smaller size than the stage and is positioned to one side of the stage during the
demo. It has a Starling layer showing some scrolling text and rotating bitmaps and
a View3D layer overlayed containing a shield with spheres rotating around it.
 
Code by Greg Caldwell, Rob Bateman & Richard Olsson
greg@geepers.co.uk
http://www.geepers.co.uk
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk

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
	import away3d.animators.*;
	import away3d.animators.data.*;
	import away3d.animators.nodes.*;
	import away3d.containers.*;
	import away3d.core.managers.*;
	import away3d.debug.*;
	import away3d.entities.*;
	import away3d.events.*;
	import away3d.library.*;
	import away3d.lights.*;
	import away3d.loaders.Loader3D;
	import away3d.loaders.parsers.*;
	import away3d.materials.*;
	import away3d.materials.lightpickers.*;
	import away3d.materials.methods.*;
	import away3d.primitives.*;
	import away3d.textures.*;
	import away3d.tools.commands.Weld;
	import away3d.utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.*;
	
	import starling.core.*;
	import starling.rootsprites.*;

	[SWF(width="800", height="600", frameRate="60")]
	public class Away3D_Starling_Layering_Demo extends Sprite
	{
		[Embed(source="../embeds/woodfloor.jpg")]
		private var WoodFloorImage:Class;
		[Embed(source="../embeds/shield.3ds", mimeType="application/octet-stream")]
		private var ShieldMesh:Class;
		[Embed(source="../embeds/hudparticle.png")]
		private var HudParticle:Class;
		
		// Stage manager and Stage3D instance proxy classes 
		private var stage3DManager:Stage3DManager;
		private var stage3DProxy1:Stage3DProxy;
		private var stage3DProxy2:Stage3DProxy;
		private var s3DProxy1HasContext : Boolean = false;
		private var s3DProxy2HasContext : Boolean = false;
		
		// Away3D engine variables
		private var away3dView1:View3D;
		private var away3dView2:View3D;
		
		// Starling engine variables
		private var starlingWallScene:Starling;
		private var starlingImpactScene:Starling;
		private var starlingHUDScene:Starling;
		
		// View 1 light objects
		private var fireLightLocation:Vector3D;
		private var fireLight:DirectionalLight;
		private var fireShadowMethod:TripleFilteredShadowMapMethod;
		private var fireLightPicker:StaticLightPicker;
		
		// View 2 light objects
		private var hudLightLocation:Vector3D;
		private var hudLight:DirectionalLight;
		private var hudShadowMethod:TripleFilteredShadowMapMethod;
		private var hudLightPicker:StaticLightPicker;
		
		// Away3D material objects
		private var floorMaterial:TextureMaterial;
		private var characterMaterial:TextureMaterial;
		private var sphereMaterial:TextureMaterial;
		private var cubeMaterial:TextureMaterial;
		private var hudSpriteMaterial:TextureMaterial;
		
		// Away3D scene objects
		private var MESH_URL:String = "assets/MaxAWDWorkflow.awd";
		private var TEXTURE_URL:String = "assets/onkba_N.jpg";
		private var characterMesh:Mesh;
		private var skeleton:Skeleton;
		private var animationSet:SkeletonAnimationSet;
		private var animator:SkeletonAnimator;
		private var floorPlane:Mesh;
		private var attackSphere:Mesh;
		private var sphereContainer:ObjectContainer3D;
		private var hudContainer : ObjectContainer3D;
		private var hudShield:Loader3D;
		private var hudContainer1:ObjectContainer3D;
		private var hudContainer2:ObjectContainer3D;
		private var hudContainer3:ObjectContainer3D;
		
		// Starling scene objects
		private var starlingWallSprite:StarlingWallSprite;
		private var starlingImpactSprite:StarlingImpactEffectSprite;
		private var starlingHUDSprite:StarlingHUDSprite;
		
		// Runtime variables
		private var startTime : Number;
		private var walkAnim : SkeletonClipNode;
		private var modelTexture : BitmapTexture;
		private var assetsThatAreloaded : Number = 0;
		private var assetsToLoad : Number = 2;
		
				
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
			
			startTime = getTimer();
			
			initProxies();
		}
		
		/**
		 * Initialise the rest of the scene when the context is available
		 */
		private function initScenes():void {
			initAway3D();
			initStarling();
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

			// Create a new Stage3D proxy for the first Stage3D scene
			stage3DProxy1 = stage3DManager.getFreeStage3DProxy();
			stage3DProxy1.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
			stage3DProxy1.color = 0x000000;

			// Create a new Stage3D proxy for the second Stage3D scene
			stage3DProxy2 = stage3DManager.getFreeStage3DProxy();
			stage3DProxy2.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
			stage3DProxy2.color = 0x000000;
			stage3DProxy2.y = 10;
			stage3DProxy2.width = 160;
			stage3DProxy2.height = 160;
		}
		
		/**
		 * Wait until both stage3DProxy instances have a Context3D
		 */
		private function onContextCreated(event : Stage3DEvent) : void {
			if (event.currentTarget == stage3DProxy1) s3DProxy1HasContext = true;
			if (event.currentTarget == stage3DProxy2) s3DProxy2HasContext = true;
			if (s3DProxy1HasContext && s3DProxy2HasContext) initScenes();
			
			// Dispatch dummy resize to position all elements
			stage.dispatchEvent(new Event(Event.RESIZE));
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
			
			//Create the second Away3D view which holds the shield HUD
			away3dView2 = new View3D();
			away3dView2.stage3DProxy = stage3DProxy2;
			away3dView2.shareContext = true;
			away3dView2.width = away3dView2.height = 160;
			
			addChild(away3dView2);
			
			addChild(new AwayStats(away3dView1, true, true));
		}
				
		/**
		 * Initialise the Starling scenes
		 */
		private function initStarling():void
		{		
			//Create the Starling scene to add the background wall/fireplace. This is positioned on top of the floor scene starting at the top of the screen. It slightly covers the wooden floor layer to avoid any gaps appearing.
			starlingWallScene = new Starling(StarlingWallSprite, stage, stage3DProxy1.viewPort, stage3DProxy1.stage3D);
			StarlingWallSprite.getInstance().touchable = false;
			
			// Create the Starling scene that shows the foreground ball impact particle effect. This appears in front of all the other layers.
			starlingImpactScene = new Starling(StarlingImpactEffectSprite, stage, stage3DProxy1.viewPort, stage3DProxy1.stage3D);
			StarlingImpactEffectSprite.getInstance().touchable = false;
			
		 	//Create the Starling scene that shows the foreground ball impact particle effect. This appears in front of all the other layers.
		 	var viewRect:Rectangle = new Rectangle(0, 0, 160, 160);
			starlingHUDScene = new Starling(StarlingHUDSprite, stage, viewRect, stage3DProxy2.stage3D);
			StarlingHUDSprite.getInstance().touchable = false;
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
			
			// Create a container for the entire HUD to help reposition in the scene
			hudContainer = new ObjectContainer3D();
			away3dView2.scene.addChild(hudContainer);
			
			//create the hud light
			hudLightLocation = new Vector3D(-465.5, -130, 200);
			hudLight = new DirectionalLight();
			hudLight.ambient = 2;
			hudLight.ambientColor = 0xa0a0a0;
			hudLight.color = 0xfffff;
			hudLight.castsShadows = true;
			hudLight.direction = hudLightLocation;
			
			//add the hud light to the HUD Away3D scene
			hudContainer.scene.addChild(hudLight);
			
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
			floorMaterial.animateUVs = true;
			floorMaterial.ambient = 2.5;
			floorMaterial.lightPicker = fireLightPicker;
			floorMaterial.normalMap = new BitmapTexture(new BitmapData(128, 128, false, 0xff807fff));
			floorMaterial.specularMap = new BitmapTexture(new BitmapData(128, 128, false, 0xffffffff));
			floorMaterial.repeat = true;
			floorMaterial.shadowMethod = fireShadowMethod;
			
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
			var particle:BitmapData = Bitmap(new HudParticle).bitmapData;
			hudSpriteMaterial = new TextureMaterial(new BitmapTexture(particle));
			hudSpriteMaterial.alphaBlending = true;
		}
		
		/**
		 * Initialise the Away3D scene objects
		 */
		private function initObjects():void
		{
			// Build the floor plane, assign the material, position it and scale it's texturing
			floorPlane = new Mesh(new PlaneGeometry(2000, 135), floorMaterial);
			floorPlane.y = -150;
			floorPlane.geometry.scaleUV(15, 1);
			away3dView1.scene.addChild(floorPlane);
			
			//build the attack sphere
			attackSphere = new Mesh(new SphereGeometry(15), sphereMaterial);
			attackSphere.x = 600;
			attackSphere.y = -40;
			
			// Build a container for the ball animation
			sphereContainer = new ObjectContainer3D();
			sphereContainer.addChild(attackSphere);
			away3dView1.scene.addChild(sphereContainer);
			
			// Load the character mesh
			AssetLibrary.enableParser(AWD2Parser);
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onCharacterResourceComplete);
			AssetLibrary.addEventListener(LoaderEvent.LOAD_ERROR, onLoadError);
			AssetLibrary.load(new URLRequest(TEXTURE_URL));
			AssetLibrary.load(new URLRequest(MESH_URL));
			
			// Build the HUD cube
			Loader3D.enableParser(Max3DSParser);
			hudShield = new Loader3D(false);
			hudShield.addEventListener(AssetEvent.MESH_COMPLETE, onShieldMeshComplete);
			hudShield.loadData(ShieldMesh);
			hudContainer.addChild(hudShield);
				
			//build the HUD particles
			var s : Sprite3D;
			
			s = new Sprite3D(hudSpriteMaterial, 70, 70);
			s.x = 350;
			hudContainer1 = new ObjectContainer3D();
			hudContainer1.addChild(s);
			hudContainer.addChild(hudContainer1);

			s = new Sprite3D(hudSpriteMaterial, 70, 70);
			s.y = 350;
			hudContainer2 = new ObjectContainer3D();
			hudContainer2.addChild(s);
			hudContainer.addChild(hudContainer2);

			s = new Sprite3D(hudSpriteMaterial, 70, 70);
			s.z = 350;
			hudContainer3 = new ObjectContainer3D();
			hudContainer3.addChild(s);
			hudContainer.addChild(hudContainer3);
		}

		protected function onLoadError(event:LoaderEvent):void
		{
			trace("Error loading: " + event.url);
		}
		
		/**
		 * Listener function for asset complete event on loader
		 */
		private function onAssetComplete(event:AssetEvent):void
		{
			// To not see these names output in the console, comment the
			// line below with two slash'es, just as you see on this line
			trace("Loaded " + event.asset.name + " Name: " + event.asset.name);
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			// Enter frame listener to manage monster Stage3D rendering
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			// Enter frame listener to manage monster Stage3D rendering
			stage3DProxy2.addEventListener(Event.ENTER_FRAME, onEnterFrameStage3DProxy);
			
			// Resize listener to handle stage resize
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		
		/**
		 * Initialise the shield and materials
		 */
		private function onShieldMeshComplete(event:AssetEvent):void
		{
			var mesh : Mesh = Mesh(event.asset);
			var mtl : ColorMaterial;
			var bmp : BitmapData;
			var ct : BitmapCubeTexture;
			var env : EnvMapMethod;
			
			bmp = new BitmapData(256, 256, false, 0);
			bmp.perlinNoise(200, 200, 2, 0, true, false, 7, true);
			
			ct = new BitmapCubeTexture(bmp, bmp, bmp, bmp, bmp, bmp);
			env = new EnvMapMethod(ct, 0.5);
			
			mtl = new ColorMaterial(0xff8800);
			mtl.lightPicker = hudLightPicker;
			mtl.addMethod(env);
			
			Weld.apply(mesh, true, false);
			
			mesh.material = mtl;
			mesh.scale(2);
		}
		
		/* 
		 * Ensure all the assets are loaded
		 */
		private function onCharacterResourceComplete(event:LoaderEvent):void
		{
			assetsThatAreloaded++;
			// check to see if we have all we need
			if (assetsThatAreloaded == assetsToLoad) {
				initCharacter();
			}
		}
		
		/**
		 * Initialise the loaded character and materials
		 */
		private function initCharacter():void {			
			// request all the things we loaded into the AssetLibrary
			skeleton = Skeleton(AssetLibrary.getAsset("Bone001"));
			walkAnim = SkeletonClipNode(AssetLibrary.getAsset("Walk"));
			modelTexture = BitmapTexture(AssetLibrary.getAsset(TEXTURE_URL));
			characterMesh = Mesh(AssetLibrary.getAsset("ONKBA-Corps-lnew"));
			
			// Create a material for the character
			var autoMap:Mapper = new Mapper(modelTexture.bitmapData);
			
			characterMaterial = new TextureMaterial(modelTexture);
			characterMaterial.normalMap = new BitmapTexture(autoMap.bitdata[1]);
			characterMaterial.specularMap = new BitmapTexture(autoMap.bitdata[2]);
			characterMaterial.gloss = 20;
			characterMaterial.ambientColor = 0x807030;
			characterMaterial.ambient = 5;
			characterMaterial.specular = 1.3;
			characterMaterial.lightPicker = fireLightPicker;
			
			// Set the size and position of the character
			characterMesh.scale(1.75);
			characterMesh.material = characterMaterial;
			characterMesh.y = -70;
			characterMesh.rotationY = 270;
			characterMesh.castsShadows = true;
			away3dView1.scene.addChild(characterMesh);

			// Define the animation 
			animationSet = new SkeletonAnimationSet(3);
			animationSet.addAnimation(walkAnim.name, walkAnim);
			
			animator = new SkeletonAnimator(animationSet, skeleton);
			animator.updatePosition = false;
			
			//apply animator to mesh
			characterMesh.animator = animator;
			
			// Begin the animation
			animator.play("Walk");
		}
		
		/**
		 * Update the character/wall/sphere/particle scene
		 */
		private function onEnterFrame(event:Event):void
		{
			// Clear the Context3D object
			stage3DProxy1.clear();
						
			// Move the scene objects in line with the monster and use the location to synchronize other scene objects.
			if (!characterMesh) return;
			
			var syncWidth:Number = 110;
			var lastPosition:Number = floorPlane.x;
			characterMesh.x += 4;
			away3dView1.camera.x = sphereContainer.x = floorPlane.x = characterMesh.x;
			
			// Update the direction of the light to approximately coincide with the position of the fireplace (Starling scene)
			fireLightLocation.x = -65 + ((characterMesh.x * 0.105) % syncWidth);
			
			// Apply light direction to Away3D light object with random jitter
			fireLight.direction = fireLightLocation.add(new Vector3D(Math.random(), Math.random(), Math.random()));
			
			// Vary the intensity of the light based on the position of the light in the scene;
			var intensity:Number = 1 - Math.abs( 2 * ((fireLightLocation.x + 9) / syncWidth));
			fireLight.diffuse = fireLight.specular = intensity;
			
			// Vary the ambient value of the monster based on the light position
			characterMaterial.ambient = 7.5 + (intensity * 3);		
			
			// (Away3D) Reposition the Wooden floor material offset (horizontal scrolling)
			floorPlane.subMeshes[0].offsetU = characterMesh.x / syncWidth * 0.85;
			
			// Scroll the background Starling wall
			starlingWallSprite = StarlingWallSprite.getInstance();
			if (starlingWallSprite) {
				starlingWallSprite.scrollWall((lastPosition - characterMesh.x) * 1.475);
				starlingWallSprite.glowIntensity = intensity;
			}
			
			// Update the attack sphere
			attackSphere.x -= 10;
			if (attackSphere.x <= 20) {
				attackSphere.x = 800;
				hudShield.scaleX = hudShield.scaleY = 1.25;
				starlingImpactSprite = StarlingImpactEffectSprite.getInstance();
				if (starlingImpactSprite)
					starlingImpactSprite.fireUp();
			}
			
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
		 * Update the HUD scene
		 */
		private function onEnterFrameStage3DProxy(event : Event):void
		{
			hudShield.rotationY = 20 * Math.sin(getTimer() * 0.001);
			hudShield.scaleX = hudShield.scaleY += (1-hudShield.scaleY) * 0.1;

			hudContainer1.rotationX -= 2.75;
			hudContainer1.rotationY += 4.38;
			hudContainer1.rotationZ -= 3.12;

			hudContainer2.rotationX += 4.8;
			hudContainer2.rotationY -= 3.1;
			hudContainer2.rotationZ -= 1.6;

			hudContainer3.rotationX += 2.5;
			hudContainer3.rotationY -= 1.1;
			hudContainer3.rotationZ += 4.6;

			//update the Starling HUD foreground (2D scrolling text)
			starlingHUDSprite = StarlingHUDSprite.getInstance();
			if (starlingHUDSprite)
				starlingHUDSprite.updateScene();
								
			//render the background Starling layer
			starlingHUDScene.nextFrame();
			
			//render the foreground Away3D layer
			away3dView2.render();
		}
		
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			// Scale the Stage3D proxy to maintain aspect ratio but fill stage width
			stage3DProxy1.width = stage.stageWidth;
			stage3DProxy1.height = 600*stage.stageWidth/800;

			stage3DProxy2.x = stage.stageWidth - 165;
		}
	}
}
