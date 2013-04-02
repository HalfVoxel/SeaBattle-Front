package sea;

import createjs.easeljs.Bitmap;
import createjs.easeljs.BitmapAnimation;
import createjs.easeljs.SpriteSheet;
import sea.Vector2;

class Effect {

	var bmpAnimation : BitmapAnimation;

	public var position : Vector2;

	public var lifetime : Float = -1;
	public var oneShot : Bool;

	var layer : Int;
	var startTime : Float;

	public function new (spriteSheet : SpriteSheet, layer : Int, oneShot = false) {
    	
    	this.layer = layer;
    	this.oneShot = oneShot;
    	startTime = sea.Seabattle.time;

        // create a BitmapAnimation instance to display and play back the sprite sheet:
        bmpAnimation = new BitmapAnimation(spriteSheet);
        
        // start playing the first sequence:
        bmpAnimation.gotoAndPlay("idle");     //animate
        
        // set up a shadow. Note that shadows are ridiculously expensive. You could display hundreds
        // of animated rats if you disabled the shadow.
        //bmpAnimation.shadow = new createjs.Shadow("#454", 0, 5, 4);
        
        bmpAnimation.name = "ShipAnim";
        bmpAnimation.scaleX = bmpAnimation.scaleY = 1.0/Seabattle.PIXEL_DENSITY;

        // have each sprite start at a specific frame
        //bmpAnimation.currentAnimationFrame = cast Math.random()*spriteSheet.getNumFrames("idle");
        
        Scene.addToLayer(bmpAnimation,layer);

        bmpAnimation.addEventListener("tick", update);
	}

	public function update () {

		var frame = Math.floor ((sea.Seabattle.time - startTime)  * bmpAnimation.spriteSheet.getAnimation("idle").frequency);
		
		bmpAnimation.currentAnimationFrame = frame % bmpAnimation.spriteSheet.getNumFrames ();

		if ((oneShot && frame >= bmpAnimation.spriteSheet.getNumFrames ()) || (lifetime >= 0 && startTime + lifetime <= sea.Seabattle.time)) {
			destroy ();
		}

		bmpAnimation.x = position.x;
		bmpAnimation.y = position.y;
	}

	public function destroy () {
		Scene.removeFromLayer (bmpAnimation,layer);
	}
}