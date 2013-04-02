package sea;

import sea.Ship;
import sea.Vector2;
import sea.Order;
import createjs.easeljs.SpriteSheet;

using sea.Vector2Utils;

class Projectile extends Sprite {

    public var source : Ship;
    public var position : Vector2;

    var hitTime : Float;
    var startPosition : Vector2;
    var dir : Vector2;
    var speed = 10.0;
    var startTime : Float;

    static var splashSpriteSheet : SpriteSheet;

    public function new (source : Ship, event : Order, time : Float) {
        super ("projectile", 4);
        this.source = source;

        var dir = (source.dir + event.dir + 4) % 4;
        this.dir = Vector2Utils.dirToVector(dir);
        hitTime = event.endTime;

        position = source.position.copy();
        startPosition = position.copy();
        startTime = time;
    }

    public override function update () {

        var factor = sea.Seabattle.time - startTime;

        if (sea.Seabattle.time >= startTime + hitTime) {
            destroy ();

            if (splashSpriteSheet == null) {
                // create spritesheet and assign the associated data.
                splashSpriteSheet = new SpriteSheet({
                    // image to use
                    images: ["assets/waterSplash.png"], 
                    // width, height & registration point of each sprite
                    frames: {width: 64, height: 64, regX: 32, regY: 32, count: 5}, 
                    animations: {
                        idle: [0, 4, "idle",12]
                    }
                });
            }

            var eff = new Effect(splashSpriteSheet,7,true);
            //eff.lifetime = splashSpriteSheet.getNumFrames() * 
            eff.position = position.copy();
        }

        factor = factor < 0 ? 0 : factor;
        position = dir.mult(speed*factor).add (startPosition);

        bitmap.x = position.x;
        bitmap.y = position.y;

    }
}