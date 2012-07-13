/* 
Framework Integration Example

Demonstrates :

A demonstration of how to combine multiple Away3D View3D instances using the same
Stage3D/Context3D via the Stage3DProxy class. Using this method, it is possible to
create independant scenes and cameras and combine them for rendering. As the stage3D
instance utilises as single depth test buffer, the scenes are combined rather than
layered.

One view3D instance contains an arrangement of cubes on a wire grid. A hovercontroller
is used to allow this scene to be rotated using the mouse. The second view3D instance
contains an arrangement of spheres which rotate but have a fixed camera position.

This particular example demonstrates how to use the automatic rendering approach of the 
Stage3DProxy class by adding the EnterFrame listener to the 'stage3DProxy' instance. The 
listener method then only needs to manage the render calls as the clear() and present()
methods are automatically called.

Code by Greg Caldwell
greg@geepers.co.uk
http://www.geepers.co.uk

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
package {
	import away3d.primitives.WireframePlane;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import away3d.containers.ObjectContainer3D;
	import away3d.primitives.SphereGeometry;
	import flash.events.MouseEvent;
	import away3d.controllers.HoverController;
	import flash.events.Event;
	import flash.display.BitmapData;
	import away3d.textures.BitmapTexture;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.entities.Mesh;
	import away3d.debug.AwayStats;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.managers.Stage3DManager;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.Sprite;

	[SWF(width="800", height="600", frameRate="60")]
	public class Simple_Away3D_Layers_AutoRender extends Sprite {
		[Embed(source="../embeds/button.png")]
		private var ButtonBitmap:Class;

		// Stage manager and proxy instances
		private var stage3DManager : Stage3DManager;
		private var stage3DProxy : Stage3DProxy;
		
		// Away3D view instances
		private var away3dView1 : View3D;
		private var away3dView2 : View3D;

		// Camera controllers 
		private var hoverController : HoverController;
				
		// Materials
		private var cubeMaterial : TextureMaterial;
		private var sphereMaterial : TextureMaterial;
		
		// Objects
		private var cube1 : Mesh;
		private var cube2 : Mesh;
		private var cube3 : Mesh;
		private var cube4 : Mesh;
		private var cube5 : Mesh;
		private var sphere1 : Mesh;
		private var sphere2 : Mesh;
		private var sphere3 : Mesh;
		private var sphere4 : Mesh;
		private var sphere5 : Mesh;
		private var sphereContainer : ObjectContainer3D;
		
		// Runtime variables
		private var lastPanAngle : Number = 0;
		private var lastTiltAngle : Number = 0;
		private var lastMouseX : Number = 0;
		private var lastMouseY : Number = 0;
		private var mouseDown : Boolean;
		private var renderOrderDesc : TextField;
		private var renderOrder : int = 0;
		
		// Constants				
		private const CUBES_SPHERES:int = 0;
		private const SPHERES_CUBES : int = 1;
		
		/**
		 * Constructor
		 */
		public function Simple_Away3D_Layers_AutoRender()
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
			initMaterials();
			initObjects();
			initButton();
			initListeners();
		}
		
		/**
		 * Initialise the Stage3D proxies
		 */
		private function initProxies():void
		{
			// Define a new Stage3DManager for the Stage3D objects
			stage3DManager = Stage3DManager.getInstance(stage);

			// Create a new Stage3D proxy to contain the separate views
			stage3DProxy = stage3DManager.getFreeStage3DProxy();
			stage3DProxy.antiAlias = 8;
			stage3DProxy.color = 0x000000;
		}

		/**
		 * Initialise the Away3D views
		 */
		private function initAway3D() : void
		{
			// Create the first Away3D view which holds the cube objects.
			away3dView1 = new View3D();
			away3dView1.stage3DProxy = stage3DProxy;
			away3dView1.shareContext = true;

			hoverController = new HoverController(away3dView1.camera, null, 45, 30, 1200, 5, 89.999);
			
			addChild(away3dView1);
			
			addChild(new AwayStats(away3dView1));
			
			//Create the second Away3D view which holds the sphere objects
			away3dView2 = new View3D();
			away3dView2.camera.z = -2000;
			away3dView2.stage3DProxy = stage3DProxy;
			away3dView2.shareContext = true;
			
			addChild(away3dView2);
		}

		/**
		 * Initialise the materials
		 */
		private function initMaterials() : void {
			//Create a material for the cubes
			var cubeBmd:BitmapData = new BitmapData(128, 128, false, 0x0);
			cubeBmd.perlinNoise(7, 7, 5, 12345, true, true);
			cubeMaterial = new TextureMaterial(new BitmapTexture(cubeBmd));
			cubeMaterial.gloss = 20;
			cubeMaterial.ambientColor = 0x808080;
			cubeMaterial.ambient = 1;
			
			//Create a material for the spheres
			var sphereBmd:BitmapData = new BitmapData(128, 128, false, 0x0);
			sphereBmd.fillRect(new Rectangle(0, 0, 128, 128), 0xffffff);
			sphereBmd.fillRect(new Rectangle(8, 8, 112, 112), 0x555555);
			sphereMaterial = new TextureMaterial(new BitmapTexture(sphereBmd));
			sphereMaterial.gloss = 20;
			sphereMaterial.ambientColor = 0x808080;
			sphereMaterial.ambient = 1;
			sphereMaterial.repeat = true;
		}

		/**
		 * Initialise the lights
		 */
		private function initObjects() : void {
			// Build the cubes for view 1
			var cG:CubeGeometry = new CubeGeometry(300, 300, 300);
			cube1 = new Mesh(cG, cubeMaterial);
			cube2 = new Mesh(cG, cubeMaterial);
			cube3 = new Mesh(cG, cubeMaterial);
			cube4 = new Mesh(cG, cubeMaterial);
			cube5 = new Mesh(cG, cubeMaterial);
			
			// Arrange them in a circle with one on the center
			cube1.x = -750; 
			cube2.z = -750;
			cube3.x = 750;
			cube4.z = 750;
			cube1.y = cube2.y = cube3.y = cube4.y = cube5.y = 150;
			
			// Add the cubes to view 1
			away3dView1.scene.addChild(cube1);
			away3dView1.scene.addChild(cube2);
			away3dView1.scene.addChild(cube3);
			away3dView1.scene.addChild(cube4);
			away3dView1.scene.addChild(cube5);
			//away3dView1.scene.addChild(new WireframePlane(20, 2500, 1.5, 0xaa7700));
			
			// Build the spheres for view 2
			var sG:SphereGeometry = new SphereGeometry(200);
			sG.scaleUV(5, 5);
			sphere1 = new Mesh(sG, sphereMaterial);
			sphere2 = new Mesh(sG, sphereMaterial);
			sphere3 = new Mesh(sG, sphereMaterial);
			sphere4 = new Mesh(sG, sphereMaterial);
			sphere5 = new Mesh(sG, sphereMaterial);

			// Arrange them in a circle with one on the center
			sphere1.x = -1000; 
			sphere2.y = -1000;
			sphere3.x = 1000;
			sphere4.y = 1000;
			
			sphereContainer = new ObjectContainer3D();
			sphereContainer.addChild(sphere1);
			sphereContainer.addChild(sphere2);
			sphereContainer.addChild(sphere3);
			sphereContainer.addChild(sphere4);
			sphereContainer.addChild(sphere5);
			away3dView2.scene.addChild(sphereContainer);
		}

		/**
		 * Initialise the button to swap the rendering orders
		 */
		private function initButton() : void {
			this.graphics.beginFill(0x0, 0.7);
			this.graphics.drawRect(0, 0, stage.stageWidth, 100);
			this.graphics.endFill();

			var button:Sprite = new Sprite();
			button.x = 130;
			button.y = 5;
			button.addChild(new ButtonBitmap());
			button.addEventListener(MouseEvent.CLICK, onChangeRenderOrder);
			addChild(button);
			
			renderOrderDesc = new TextField();
			renderOrderDesc.defaultTextFormat = new TextFormat("_sans", 11, 0xffff00);
			renderOrderDesc.width = stage.stageWidth;
			renderOrderDesc.x = 300;
			renderOrderDesc.y = 5;
			addChild(renderOrderDesc);
			
			updateRenderDesc();
		}

		/**
		 * Set up the rendering processing event listeners
		 */
		private function initListeners() : void {
			stage3DProxy.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		/**
		 * The main rendering loop
		 */
		private function onEnterFrame(event : Event) : void {
			// Update the hovercontroller for view 1
			if (mouseDown) {
				hoverController.panAngle = 0.3 * (stage.mouseX - lastMouseX) + lastPanAngle;
				hoverController.tiltAngle = 0.3 * (stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			
			// Rotate view 2
			sphereContainer.rotationZ += 0.5;
			
			// Use the selected rendering order
			if (renderOrder == CUBES_SPHERES) {
				// Render the Away3D layer 1
				away3dView1.render();
				
				// Render the Away3D layer 2
				away3dView2.render();
			} else {
				// Render the Away3D layer 2
				away3dView2.render();
				
				// Render the Away3D layer 1
				away3dView1.render();
			}
		}

		/**
		 * Handle the mouse down event and remember details for hovercontroller
		 */
		private function onMouseDown(event : MouseEvent) : void {
			mouseDown = true;
			lastPanAngle = hoverController.panAngle;
			lastTiltAngle = hoverController.tiltAngle;
			lastMouseX = stage.mouseX;
			lastMouseY = stage.mouseY;
		}

		/**
		 * Clear the mouse down flag to stop the hovercontroller
		 */
		private function onMouseUp(event : MouseEvent) : void {
			mouseDown = false; 
		}

		/**
		 * Swap the rendering order 
		 */
		private function onChangeRenderOrder(event : MouseEvent) : void {
			renderOrder = (renderOrder == CUBES_SPHERES) ? SPHERES_CUBES : CUBES_SPHERES;
			
			updateRenderDesc();
		}		

		/**
		 * Change the text describing the rendering order
		 */
		private function updateRenderDesc() : void {
			var txt:String = "Demo of rendering two Away3D View3D instances using the Stage3DManager & Stage3DProxy\n";
			txt += "framework integration code. One view3D has uses HoverController whilst the other camera is fixed.\n";
			txt += "Due to depth testing, both views are combined, irrespective or render ordering\n";
			txt += "EnterFrame is attached to the Stage3DProxy - clear()/present() are handled automatically\n\n";
			switch (renderOrder) {
				case CUBES_SPHERES : txt += "Render Order (first:behind to last:in-front) : Cubes > Spheres\nNOTE: Due to depth testing, both views are combined, irrespective or render ordering"; break;
				case SPHERES_CUBES : txt += "Render Order (first:behind to last:in-front) : Spheres > Cubes\nNOTE: Due to depth testing, both views are combined, irrespective or render ordering"; break;
			}
			renderOrderDesc.text = txt;
		}
	}
}
