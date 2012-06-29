/* 
Framework Integration Example

Demonstrates :

A demonstration of how to combine multiple Starling instances using the same
Stage3D/Context3D via the Stage3DProxy class. Using this method, it is possible to
create independant Starling scenes that can be layered as required.

In this example, one Starling sprite scene contains a bitmap/transparent checkerboard 
that is centered on the display and is rotated. The second Starling sprite scene is a 
continuous particle effect. 

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
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.events.Stage3DEvent;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import starling.core.Starling;
	import starling.rootsprites.StarlingCheckerboardSprite;
	import starling.rootsprites.StarlingStarsSprite;

	[SWF(width="800", height="600", frameRate="60")]
	public class Simple_Starling_Layers_AutoRender extends Sprite {
		[Embed(source="../embeds/button.png")]
		private var ButtonBitmap:Class;

		// Stage manager and proxy instances
		private var stage3DManager : Stage3DManager;
		private var stage3DProxy : Stage3DProxy;
		
		// Starling instances
		private var starlingStars:Starling;
		private var starlingCheckerboard:Starling;

		// Runtime variables
		private var renderOrderDesc : TextField;
		private var renderOrder : int = 0;
		
		// Constants				
		private const STARS_CHECKERS:int = 0;
		private const CHECKERS_STARS : int = 1;
		
		/**
		 * Constructor
		 */
		public function Simple_Starling_Layers_AutoRender()
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
			stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
			stage3DProxy.antiAlias = 8;
			stage3DProxy.color = 0x222277;
			stage3DProxy.enableDepthAndStencil = false;
		}

		private function onContextCreated(event : Stage3DEvent) : void {
			initStarling();
			initButton();
			initListeners();
		}

		/**
		 * Initialise the Starling sprite layers
		 */
		private function initStarling() : void
		{
			//Create the Starling scene to add the background wall/fireplace. This is positioned on top of the floor scene starting at the top of the screen. It slightly covers the wooden floor layer to avoid any gaps appearing.
			starlingStars = new Starling(StarlingStarsSprite, stage, stage3DProxy.viewPort, stage3DProxy.stage3D);

			//Create the Starling scene to add the background wall/fireplace. This is positioned on top of the floor scene starting at the top of the screen. It slightly covers the wooden floor layer to avoid any gaps appearing.
			starlingCheckerboard = new Starling(StarlingCheckerboardSprite, stage, stage3DProxy.viewPort, stage3DProxy.stage3D);
		}

		/**
		 * Initialise the button to swap the rendering orders
		 */
		private function initButton() : void {
			this.graphics.beginFill(0x0, 0.7);
			this.graphics.drawRect(0, 0, stage.stageWidth, 100);
			this.graphics.endFill();

			var button:Sprite = new Sprite();
			button.x = 5;
			button.y = 5;
			button.addChild(new ButtonBitmap());
			button.addEventListener(MouseEvent.CLICK, onChangeRenderOrder);
			addChild(button);
			
			renderOrderDesc = new TextField();
			renderOrderDesc.defaultTextFormat = new TextFormat("_sans", 11, 0xffff00);
			renderOrderDesc.width = stage.stageWidth;
			renderOrderDesc.x = 175;
			renderOrderDesc.y = 5;
			addChild(renderOrderDesc);
			
			updateRenderDesc();
		}

		/**
		 * Set up the rendering processing event listeners
		 */
		private function initListeners() : void {
			stage3DProxy.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		/**
		 * The main rendering loop
		 */
		private function onEnterFrame(event : Event) : void {
			// Update the scenes
			var starlingCheckerboardSprite:StarlingCheckerboardSprite = StarlingCheckerboardSprite.getInstance();
			if (starlingCheckerboardSprite)
				starlingCheckerboardSprite.update();
			
			// Use the selected rendering order
			if (renderOrder == STARS_CHECKERS) {
				// Render the Starling stars layer
				starlingStars.nextFrame();
				
				// Render the Starling animation layer
				starlingCheckerboard.nextFrame();
			} else {
				// Render the Starling animation layer
				starlingCheckerboard.nextFrame();

				// Render the Starling stars layer
				starlingStars.nextFrame();				
			}
		}
		
		/**
		 * Swap the rendering order 
		 */
		private function onChangeRenderOrder(event : MouseEvent) : void {
			renderOrder = (renderOrder == STARS_CHECKERS) ? CHECKERS_STARS : STARS_CHECKERS;
			
			updateRenderDesc();
		}		

		/**
		 * Change the text describing the rendering order
		 */
		private function updateRenderDesc() : void {
			var txt:String = "Demo of integrating two Starling framework layers onto a stage3D instance.\n";
			txt += "One layer contains a rotating bitmap checkerboard whilst the other contains a particle effect.\n";
			txt += "EnterFrame is attached to the Stage3DProxy - clear()/present() are handled automatically\n\n\n";
			switch (renderOrder) {
				case STARS_CHECKERS : txt += "Render Order (first:behind to last:in-front) : Stars > Checkerboard"; break;
				case CHECKERS_STARS : txt += "Render Order (first:behind to last:in-front) : Checkerboard > Stars"; break;
			}
			renderOrderDesc.text = txt;
		}
	}
}
