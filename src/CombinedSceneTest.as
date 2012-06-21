package {
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.AwayStats;
	import away3d.events.Stage3DEvent;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import starling.core.Starling;

	[SWF(width="800", height="600", frameRate="60")]
	public class CombinedSceneTest extends Sprite {
		// Stage manager and Stage3D instance proxy classes
		private var _stage3DManager : Stage3DManager;
		private var _scene1Proxy : Stage3DProxy;
		private var _scene2Proxy : Stage3DProxy;
		// Scene 1 objects
		private var _s2DWallScene : Starling;
		private var _s2DWallSceneInstance : StarlingWallScene;
		private var _a3DCharacterScene : Away3DCharacterScene;
		private var _s2DImpactEffectScene : Starling;
		private var _s2DImpactEffectSceneInstance : StarlingImpactEffectScene;
		// Scene 2 objects
		private var _a3DHUDBackground : Away3DHUDBackground;
		private var _s2DHUDScene : Starling;
		private var _s2DHUDSceneInstance : StarlingHUDScene;
		// Counter to ensure all Stage3D instances have been created correctly
		private var _stage3DInstances : Number;
		// A counter to reposition the HUD using sin(bounceCtr)
		private var bounceCtr : Number = 0;
		private var _renderScene2 : Boolean;

		public function CombinedSceneTest() {
			// Wait for the application to be ready on the stage
			this.addEventListener(Event.ADDED_TO_STAGE, initApp);
		}

		private function initApp(event : Event) : void {
			// Remove the ADDED_TO_STAGE event listener
			this.removeEventListener(Event.ADDED_TO_STAGE, initApp);

			// Define a new LayerManager and wait for it's Context3D top be available
			_stage3DManager = Stage3DManager.getInstance(stage);

			// Reset the stage3D counter so we know we have all the handles we need
			_stage3DInstances = 0;

			// Wait until there is a valid context and handle on the Stage3D instance
			_scene1Proxy = _stage3DManager.getFreeStage3DProxy();

			// Set the properties for the Stage3D instance for scene 1
			_scene1Proxy.color = 0x66aa00;
			_scene1Proxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContext3DActive);

			// Set the properties for the Stage3D instance for scene 2
			_scene2Proxy = _stage3DManager.getFreeStage3DProxy();
			_scene2Proxy.color = 0x000000;
			_scene2Proxy.x = stage.stageWidth - 256;
			_scene2Proxy.y = 50;
			_scene2Proxy.width = 256;
			_scene2Proxy.height = 256;

			_scene2Proxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContext3DActive);
		}

		private function onContext3DActive(e : Stage3DEvent) : void {
			// Once both stage3D instances have been created continue with the demo
			_stage3DInstances++;
			if (_stage3DInstances == 2) buildScenes();
		}

		private function buildScenes() : void {
			// Set the stage position and alignment properties
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			// Scene 1 : Build our 2D (Wall), 3D (Monster & ball) and 2D (Impact effect) scenes for scene 1
			build_Starling_Wall_Scene();
			// Background layer
			build_Away3D_Character_Scene();
			// Mid layer
			build_Starling_Ball_Impact_Effect_Scene();
			// Foreground layer

			// Scene 2 : Build our 3D (Rotating cube) and 2D (HUD and scrolling text) scenes for scene 2
			build_Away3D_HUD_Scene();
			// Background layer
			build_Starling_HUD_Scene();
			// Foreground layer
			_renderScene2 = true;

			// Add an Enter_Frame event to manage our layer rendering for scene 1.
			_scene2Proxy.addEventListener(Event.ENTER_FRAME, onEnterFrameProxy);

			this.addEventListener(MouseEvent.CLICK, toggleScene2Rendering);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);

			stage.addEventListener(Event.RESIZE, onResize);

			onResize();
		}

		/*
		 * Create the Starling scene to add the background wall/fireplace. This
		 * is positioned on top of the floor scene starting at the top of the screen.
		 * It slightly covers the wooden floor layer to avoid any gaps appearing.
		 */
		private function build_Starling_Wall_Scene() : void {
			_s2DWallScene = new Starling(StarlingWallScene, stage, _scene1Proxy.viewPort, _scene1Proxy.stage3D);
			_s2DWallScene.deferContextCalls = true;

			_s2DWallSceneInstance = StarlingWallScene.getInstance();
		}

		/*
		 * Create the Starling scene that shows the foreground ball impact
		 * particle effect. This appears in front of all the other layers.
		 */
		private function build_Starling_Ball_Impact_Effect_Scene() : void {
			_s2DImpactEffectScene = new Starling(StarlingImpactEffectScene, stage, _scene1Proxy.viewPort, _scene1Proxy.stage3D);
			_s2DImpactEffectScene.deferContextCalls = true;

			_s2DImpactEffectSceneInstance = StarlingImpactEffectScene.getInstance();
		}

		/*
		 * Create the Away3D animated character layer which includes
		 * the monster and the flying ball object.
		 */
		private function build_Away3D_Character_Scene() : void {
			_a3DCharacterScene = new Away3DCharacterScene();
			_a3DCharacterScene.stage3DProxy = _scene1Proxy;
			_a3DCharacterScene.deferContextCalls = true;

			this.addChild(_a3DCharacterScene);

			this.addChild(new AwayStats());
		}

		/*
		 * Create the Away3D animated character layer which includes
		 * the monster and the flying ball object.
		 */
		private function build_Away3D_HUD_Scene() : void {
			_a3DHUDBackground = new Away3DHUDBackground();
			_a3DHUDBackground.stage3DProxy = _scene2Proxy;
			_a3DHUDBackground.deferContextCalls = true;

			this.addChild(_a3DHUDBackground);
		}

		/*
		 * Create the Starling scene that shows the foreground ball impact
		 * particle effect. This appears in front of all the other layers.
		 */
		private function build_Starling_HUD_Scene() : void {
			_s2DHUDScene = new Starling(StarlingHUDScene, stage, _scene2Proxy.viewPort, _scene2Proxy.stage3D);
			_s2DHUDScene.deferContextCalls = true;

			_s2DHUDSceneInstance = StarlingHUDScene.getInstance();
		}

		private function onEnterFrameProxy(event : Event) : void {
			_a3DHUDBackground.render();
			_s2DHUDScene.renderFrame();
		}

		private function onEnterFrame(event : Event) : void {
			// (Away3D) Reposition the Wooden floor texture offset
			_a3DCharacterScene.floorOffset += 0.04;

			// Starling Wall background scroll
			_s2DWallSceneInstance.scrollWall(-5.5);

			// Away3D View 2 processing
			_a3DCharacterScene.updateScene();
			_a3DCharacterScene.sphere.x -= 10;
			if (_a3DCharacterScene.sphere.x <= 40) {
				_a3DCharacterScene.sphere.x = 300;
				_s2DImpactEffectSceneInstance.fireUp();
			}

			// Update the HUD display (3D cube and 2D scrolling text)
			_a3DHUDBackground.updateScene();
			_s2DHUDSceneInstance.updateScene();

			// Render phase.
			// 1. Call the Stage3DManager.initialiseRender();
			// 2. Render each layer (bottom to top)
			// 3. Call the Stage3DManager.finaliseRender();

			// Scene 1 - the horizontal scrolling wall and monster with particle fire and
			// impact effect
			_scene1Proxy.clear();

			_s2DWallScene.renderFrame();
			_a3DCharacterScene.render();
			_s2DImpactEffectScene.renderFrame();

			_scene1Proxy.present();

			bounceCtr += 0.04;
			_scene2Proxy.y = (stage.stageHeight - 256) * ((Math.sin(bounceCtr) + 1) / 2);
		}

		/*
		 * Resize the scenes to match the new stage sizes.
		 * Scene 1 is scaled whilst maintaining the aspect ratio
		 * Scene 2 is repositioned against the right of the stage
		 */
		private function onResize(event : Event = null) : void {
			// Scale scene 1 even to maintain the aspect ratio but fill the width
			// even though stageScaleMode is NO_SCALE.
			_scene1Proxy.width = stage.stageWidth;
			_scene1Proxy.height = 600 * stage.stageWidth / 800;

			_scene2Proxy.x = stage.stageWidth - 256;
		}

		private function toggleScene2Rendering(event : MouseEvent) : void {
			_renderScene2 = !_renderScene2;

			if (_renderScene2) 
			// Calling with a valid stage will start the rendering
				_scene2Proxy.addEventListener(Event.ENTER_FRAME, onEnterFrameProxy);
			else
			// Calling with no parameter will halt the rendering
				_scene2Proxy.removeEventListener(Event.ENTER_FRAME, onEnterFrameProxy);
		}
	}
}
