/* 
Framework Integration Example

Demonstrates :

An advanced example of multiple frameworks being layered together on multiple
stage3D/context3D instances via the Stage3DProxy class. This is and extreme example
using two Stage3DProxies. The first Stage3DProxy instance contains a scrolling background
wall using the Starling framework with a particle based fire. Layered on top of this is 
an Away3D View3D instance containing an animated MD5 model casting a shadow onto a floor 
plane. Also in the same View3D a sphere continually impacts the MD5 model which triggers
a particle effect in a secondary Starling layer on top of the View3D layer. 

The second Stage3DProxy instance is overlayed on the first instance and acts like a HUD.
It has a smaller size than the stage and is also repositioned on the stage during the
demo. It has a View3D layer containing rotating cube with spheres rotating around it and
a Starling layer overlayed showing some scrolling text and rotating bitmaps.
 
Code by Greg Caldwell & Rob Bateman
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
	import away3d.animators.AnimatorBase;
	import away3d.animators.BlendingSkeletonAnimator;
	import away3d.animators.PathAnimator;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.SkeletonAnimatorBase;
	import away3d.animators.SmoothSkeletonAnimator;
	import away3d.animators.UVAnimator;
	import away3d.animators.VertexAnimator;
	import away3d.animators.data.AnimationBase;
	import away3d.animators.data.AnimationSequenceBase;
	import away3d.animators.data.AnimationStateBase;
	import away3d.animators.data.NullAnimation;
	import away3d.animators.data.SkeletonAnimation;
	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.data.SkeletonAnimationState;
	import away3d.animators.data.UVAnimationFrame;
	import away3d.animators.data.UVAnimationSequence;
	import away3d.animators.data.VertexAnimation;
	import away3d.animators.data.VertexAnimationMode;
	import away3d.animators.data.VertexAnimationSequence;
	import away3d.animators.data.VertexAnimationState;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.managers.AGALProgram3DCache;
	import away3d.core.managers.Mouse3DManager;
	import away3d.core.managers.RTTBufferManager;
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.AwayStats;
	import away3d.debug.Debug;
	import away3d.debug.Trident;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.entities.SegmentSet;
	import away3d.entities.Sprite3D;
	import away3d.entities.TextureProjector;
	import away3d.events.AnimatorEvent;
	import away3d.events.AssetEvent;
	import away3d.events.GeometryEvent;
	import away3d.events.LensEvent;
	import away3d.events.LoaderEvent;
	import away3d.events.MouseEvent3D;
	import away3d.events.Object3DEvent;
	import away3d.events.ParserEvent;
	import away3d.events.PathEvent;
	import away3d.events.Scene3DEvent;
	import away3d.events.ShadingMethodEvent;
	import away3d.events.Stage3DEvent;
	import away3d.library.AssetLibrary;
	import away3d.library.AssetLibraryBundle;
	import away3d.library.assets.AssetType;
	import away3d.library.assets.BitmapDataAsset;
	import away3d.library.assets.IAsset;
	import away3d.library.assets.NamedAssetBase;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.LightProbe;
	import away3d.lights.PointLight;
	import away3d.loaders.parsers.AC3DParser;
	import away3d.loaders.parsers.AWD1Parser;
	import away3d.loaders.parsers.AWD2Parser;
	import away3d.loaders.parsers.AWDParser;
	import away3d.loaders.parsers.DAEParser;
	import away3d.loaders.parsers.ImageParser;
	import away3d.loaders.parsers.MD2Parser;
	import away3d.loaders.parsers.MD5AnimParser;
	import away3d.loaders.parsers.MD5MeshParser;
	import away3d.loaders.parsers.Max3DSParser;
	import away3d.loaders.parsers.OBJParser;
	import away3d.loaders.parsers.ParserBase;
	import away3d.loaders.parsers.ParserDataFormat;
	import away3d.loaders.parsers.Parsers;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.materials.DefaultMaterialBase;
	import away3d.materials.LightSources;
	import away3d.materials.MaterialBase;
	import away3d.materials.SegmentMaterial;
	import away3d.materials.SkyBoxMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.VideoMaterial;
	import away3d.materials.lightpickers.LightPickerBase;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.AlphaMaskMethod;
	import away3d.materials.methods.AnisotropicSpecularMethod;
	import away3d.materials.methods.BasicAmbientMethod;
	import away3d.materials.methods.BasicDiffuseMethod;
	import away3d.materials.methods.BasicNormalMethod;
	import away3d.materials.methods.BasicSpecularMethod;
	import away3d.materials.methods.CelDiffuseMethod;
	import away3d.materials.methods.CelSpecularMethod;
	import away3d.materials.methods.ColorMatrixMethod;
	import away3d.materials.methods.ColorTransformMethod;
	import away3d.materials.methods.CompositeDiffuseMethod;
	import away3d.materials.methods.CompositeSpecularMethod;
	import away3d.materials.methods.DepthDiffuseMethod;
	import away3d.materials.methods.DitheredShadowMapMethod;
	import away3d.materials.methods.EffectMethodBase;
	import away3d.materials.methods.EnvMapAmbientMethod;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.FogMethod;
	import away3d.materials.methods.FresnelEnvMapMethod;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.materials.methods.HeightMapNormalMethod;
	import away3d.materials.methods.LightMapDiffuseMethod;
	import away3d.materials.methods.LightMapMethod;
	import away3d.materials.methods.LightingMethodBase;
	import away3d.materials.methods.MethodVO;
	import away3d.materials.methods.NearShadowMapMethod;
	import away3d.materials.methods.OutlineMethod;
	import away3d.materials.methods.ProjectiveTextureMethod;
	import away3d.materials.methods.RefractionEnvMapMethod;
	import away3d.materials.methods.RimLightMethod;
	import away3d.materials.methods.ShadingMethodBase;
	import away3d.materials.methods.ShadowMapMethodBase;
	import away3d.materials.methods.SimpleWaterNormalMethod;
	import away3d.materials.methods.SoftShadowMapMethod;
	import away3d.materials.methods.SpecularShadingModel;
	import away3d.materials.methods.SubsurfaceScatteringDiffuseMethod;
	import away3d.materials.methods.TerrainDiffuseMethod;
	import away3d.materials.methods.TripleFilteredShadowMapMethod;
	import away3d.materials.methods.WrapDiffuseMethod;
	import away3d.primitives.CapsuleGeometry;
	import away3d.primitives.ConeGeometry;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.LineSegment;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.PrimitiveBase;
	import away3d.primitives.RegularPolygonGeometry;
	import away3d.primitives.SkyBox;
	import away3d.primitives.SphereGeometry;
	import away3d.primitives.TorusGeometry;
	import away3d.primitives.WireframeAxesGrid;
	import away3d.primitives.WireframeCube;
	import away3d.primitives.WireframeCylinder;
	import away3d.primitives.WireframeGrid;
	import away3d.primitives.WireframePlane;
	import away3d.primitives.WireframePrimitiveBase;
	import away3d.primitives.WireframeSphere;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.BitmapTexture;
	import away3d.textures.BitmapTextureCache;
	import away3d.textures.CubeTextureBase;
	import away3d.textures.RenderCubeTexture;
	import away3d.textures.RenderTexture;
	import away3d.textures.SpecularBitmapTexture;
	import away3d.textures.SplatBlendBitmapTexture;
	import away3d.textures.Texture2DBase;
	import away3d.textures.TextureProxyBase;
	import away3d.textures.VideoTexture;
	import away3d.textures.WebcamTexture;
	import away3d.utils.Cast;
	import flash.display.AVM1Movie;
	import flash.display.ActionScriptVersion;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.CapsStyle;
	import flash.display.ColorCorrection;
	import flash.display.ColorCorrectionSupport;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.FocusDirection;
	import flash.display.FrameLabel;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.GraphicsBitmapFill;
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsGradientFill;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsPathWinding;
	import flash.display.GraphicsShaderFill;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.GraphicsTrianglePath;
	import flash.display.IBitmapDrawable;
	import flash.display.IDrawCommand;
	import flash.display.IGraphicsData;
	import flash.display.IGraphicsFill;
	import flash.display.IGraphicsPath;
	import flash.display.IGraphicsStroke;
	import flash.display.InteractiveObject;
	import flash.display.InterpolationMethod;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MorphShape;
	import flash.display.MovieClip;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.PixelSnapping;
	import flash.display.SWFVersion;
	import flash.display.Scene;
	import flash.display.Shader;
	import flash.display.ShaderData;
	import flash.display.ShaderInput;
	import flash.display.ShaderJob;
	import flash.display.ShaderParameter;
	import flash.display.ShaderParameterType;
	import flash.display.ShaderPrecision;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.display.TriangleCulling;
	import flash.events.AccelerometerEvent;
	import flash.events.ActivityEvent;
	import flash.events.AsyncErrorEvent;
	import flash.events.ContextMenuEvent;
	import flash.events.DRMAuthenticateEvent;
	import flash.events.DRMAuthenticationCompleteEvent;
	import flash.events.DRMAuthenticationErrorEvent;
	import flash.events.DRMCustomProperties;
	import flash.events.DRMDeviceGroupErrorEvent;
	import flash.events.DRMDeviceGroupEvent;
	import flash.events.DRMErrorEvent;
	import flash.events.DRMStatusEvent;
	import flash.events.DataEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.EventPhase;
	import flash.events.FocusEvent;
	import flash.events.FullScreenEvent;
	import flash.events.GameInputEvent;
	import flash.events.GeolocationEvent;
	import flash.events.GestureEvent;
	import flash.events.GesturePhase;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IMEEvent;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NetDataEvent;
	import flash.events.NetFilterEvent;
	import flash.events.NetMonitorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.OutputProgressEvent;
	import flash.events.PressAndTapGestureEvent;
	import flash.events.ProgressEvent;
	import flash.events.SampleDataEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.ShaderEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.events.SoftKeyboardTrigger;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.events.StageVideoEvent;
	import flash.events.StatusEvent;
	import flash.events.SyncEvent;
	import flash.events.TextEvent;
	import flash.events.ThrottleEvent;
	import flash.events.ThrottleType;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.events.TransformGestureEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.events.UncaughtErrorEvents;
	import flash.events.VideoEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.core.StatsDisplay;
	import starling.core.TouchMarker;
	import starling.core.TouchProcessor;
	import starling.core.starling_internal;
	import starling.rootsprites.StarlingHUDSprite;
	import starling.rootsprites.StarlingImpactEffectSprite;
	import starling.rootsprites.StarlingWallSprite;



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
		private var s3DProxy1hasContext : Boolean = false;
		private var s3DProxy2hasContext : Boolean = false;
		
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
		private var hellKnightMaterial:TextureMaterial;
		private var sphereMaterial:TextureMaterial;
		private var cubeMaterial:TextureMaterial;
		private var ballMaterial:TextureMaterial;
		
		// Away3D scene objects
		private var hellKnightMesh:Mesh;
		private var hellKnightAnimator:SmoothSkeletonAnimator;
		private var floorPlane:Mesh;
		private var attackSphere:Mesh;
		private var sphereContainer:ObjectContainer3D;
		private var hudCube:Mesh;
		private var hudContainer1:ObjectContainer3D;
		private var hudContainer2:ObjectContainer3D;
		private var hudContainer3:ObjectContainer3D;
		
		// Starling scene objects
		private var starlingWallSprite:StarlingWallSprite;
		private var starlingImpactSprite:StarlingImpactEffectSprite;
		private var starlingHUDSprite:StarlingHUDSprite;
		
		// Runtime variables
		private var sinCount:Number = 0;
		private var activeHUD : Boolean = false;
		private var startTime : Number;
		
				
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

			// Create a new Stage3D proxy for the first Stage3D object
			stage3DProxy1 = stage3DManager.getFreeStage3DProxy();
			stage3DProxy1.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
			stage3DProxy1.color = 0x000000;

			// Create a new Stage3D proxy for the second Stage3D object
			stage3DProxy2 = stage3DManager.getFreeStage3DProxy();
			stage3DProxy2.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
			stage3DProxy2.color = 0x000000;
			stage3DProxy2.y = 5;
			stage3DProxy2.width = 256;
			stage3DProxy2.height = 256;
		}
		
		/**
		 * Wait until both stage3DProxy instances have a Context3D
		 */
		private function onContextCreated(event : Stage3DEvent) : void {
			if (event.currentTarget == stage3DProxy1) s3DProxy1hasContext = true;
			if (event.currentTarget == stage3DProxy2) s3DProxy2hasContext = true;
			if (s3DProxy1hasContext && s3DProxy2hasContext) initScenes();
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
			
			// Create the Starling scene that shows the foreground ball impact particle effect. This appears in front of all the other layers.
			starlingImpactScene = new Starling(StarlingImpactEffectSprite, stage, stage3DProxy1.viewPort, stage3DProxy1.stage3D);
			
		 	//Create the Starling scene that shows the foreground ball impact particle effect. This appears in front of all the other layers.
			starlingHUDScene = new Starling(StarlingHUDSprite, stage, stage3DProxy2.viewPort, stage3DProxy2.stage3D);
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
			floorMaterial.animateUVs = true;
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
			//hellKnightMaterial.shadowMethod = fireShadowMethod;
			
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
			//ballMaterial.shadowMethod = hudShadowMethod;

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
			// Move the scene objects in line with the monster and use the location to synchronize other scene objects.
			if (!hellKnightMesh) return;
			
			var syncWidth:Number = 110;
			var lastPosition:Number = floorPlane.x;
			
			away3dView1.camera.x = sphereContainer.x = floorPlane.x = hellKnightMesh.x;
			
			// Update the direction of the light to approximately coincide with the position of the fireplace (Starling scene)
			fireLightLocation.x = -65 + ((hellKnightMesh.x * 0.105) % syncWidth);
			
			// Apply light direction to Away3D light object with random jitter
			fireLight.direction = fireLightLocation.add(new Vector3D(Math.random(), Math.random(), Math.random()));
			
			// Vary the intensity of the light based on the position of the light in the scene;
			var intensity:Number = 1 - Math.abs( 2 * ((fireLightLocation.x + 9) / syncWidth));
			fireLight.diffuse = fireLight.specular = intensity;
			
			// Vary the ambient value of the monster based on the light position
			hellKnightMaterial.ambient = 7.5 + (intensity * 3);		
			
			// (Away3D) Reposition the Wooden floor material offset (horizontal scrolling)
			floorPlane.subMeshes[0].offsetU = hellKnightMesh.x / syncWidth * 0.85;
			
			// Scroll the background Starling wall
			starlingWallSprite = StarlingWallSprite.getInstance();
			if (starlingWallSprite) {
				starlingWallSprite.scrollWall((lastPosition - hellKnightMesh.x) * 1.475);
				starlingWallSprite.glowIntensity = intensity;
			}
			
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
