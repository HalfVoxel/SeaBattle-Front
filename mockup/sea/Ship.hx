package sea;
import sea.Vector2;
import sea.Seabattle;
import sea.Order;
using sea.Vector2Utils;

import createjs.easeljs.Shape;
import createjs.easeljs.Stage;
import createjs.easeljs.Bitmap;
import createjs.easeljs.BitmapAnimation;
import createjs.easeljs.SpriteSheet;
import createjs.tweenjs.Ease;
import createjs.tweenjs.Tween;

class Ship implements HasPosition {
    public var position : Vector2;
    public var realPosition : Vector2;
    public var realDir : Int = 0;
    public var dir : Int = 0;
    public var angle : Float = 0;

    var bmpAnimation : BitmapAnimation;

    static var spriteSheet : SpriteSheet;

    public var orders : Array<Order>;

    var time = 0.0;

    public function new () {
        position = {x: 0, y:0};
        realPosition = position.copy();
        orders = new Array<Order> ();

        if (spriteSheet == null) {
            trace ("Loading SpriteSheet");
            // create spritesheet and assign the associated data.
            spriteSheet = new SpriteSheet({
                // image to use
                images: ["assets/ship.png"], 
                // width, height & registration point of each sprite
                frames: {width: 64, height: 64, regX: 32, regY: 32, count: 4}, 
                animations: {    
                    idle: [0, 3, "idle",10]
                }
            });
        }
        
        // create a BitmapAnimation instance to display and play back the sprite sheet:
        bmpAnimation = new BitmapAnimation(spriteSheet);
        
        // start playing the first sequence:
        bmpAnimation.gotoAndPlay("idle");     //animate
        
        // set up a shadow. Note that shadows are ridiculously expensive. You could display hundreds
        // of animated rats if you disabled the shadow.
        //bmpAnimation.shadow = new createjs.Shadow("#454", 0, 5, 4);
        
        bmpAnimation.name = "ShipAnim";
        bmpAnimation.x = 16;
        bmpAnimation.y = 32;
        
        // have each monster start at a specific frame
        bmpAnimation.currentAnimationFrame = cast Math.random()*spriteSheet.getNumFrames("idle");
        trace (Math.random()*spriteSheet.getNumFrames("idle"));
        Seabattle.stage.addChild(bmpAnimation);
    }

    public function update () {
        var p = Seabattle.worldToScreen(position);
        bmpAnimation.x = p.x;
        bmpAnimation.y = p.y;
        bmpAnimation.rotation = angle+90;//dirToAngle(dir) + 90;
    }

    public function pushOrder (order : Order) {
        orders.push (order);
        //trace (order);
    }

    public function popOrder () {
        if (orders.length > 0) {
            orders.pop();
            return true;
        } else {
            return false;
        }
    }

    public function simulateTime (t : Float) {
        /*if (num == currentOrder) return;

        if (num < currentOrder) {

        }*/
        t = t < 0 ? 0 : t;
        t = t > orders.length ? orders.length : t;

        if (t == 0) {
            position = realPosition.copy();
            dir = realDir;
            angle = dirToAngle(dir);
            return;
        }

        var orderBase = Math.floor (t);
        position = realPosition.copy();
        dir = realDir;

        //trace ("Simulating time " + t + " with base " + orderBase);

        for (i in 0...orderBase) {
            var order = orders[i];
            if (order.type == OrderType.Move) {
                if (order.dir != 0) {
                    position = position.add (dirToVector(dir));
                }
                dir = (dir+order.dir+4) % 4;
                position = position.add (dirToVector(dir));
            }
        }

        angle = dirToAngle(dir);

        t -= orderBase;
        if (t > 0.01) {
            var newPos = position.copy();
            var order = orders[orderBase];
            var newDir = dir;
            if (order.type == OrderType.Move) {
                if (order.dir != 0) {
                    newPos = newPos.add (dirToVector(newDir));
                }
                newDir = (newDir+order.dir+4) % 4;
                newPos = newPos.add (dirToVector(dir));
            }

            if (order.dir == 0) {
                position = Vector2Utils.lerp (position, newPos, t);
            } else {
                //Turning required
                var rotPos = position.add(dirToVector(newDir));
                var a = dirToAngle ((newDir+2) % 4);
                var b = dirToAngle (dir);

                var aa = dirToAngle (dir);
                var ab = dirToAngle (newDir);

                if (order.dir == 1) {
                    //CW
                    if (b < a) b += 360;
                    if (ab < aa) ab += 360;

                    var ra = (a + (b-a)*t) % 360;
                    position = rotPos.add (Vector2Utils.vectorFromAngle(ra));
                    angle = (aa + (ab-aa)*t) % 360;
                } else {
                    //CCW
                    if (b > a) a += 360;
                    if (ab > aa) aa += 360;

                    var ra = (a + (b-a)*t) % 360;
                    position = rotPos.add (Vector2Utils.vectorFromAngle(ra));
                    angle = (aa + (ab-aa)*t) % 360;
                }
            }
        }
    }

    static var dirVectors : Array<Vector2> = [{x:1,y:0},{x:0,y:1},{x:-1,y:0},{x:0,y:-1}];
    function dirToVector (dir : Int) {
        return dirVectors[dir];
    }

    function dirToAngle (dir : Float) {
        return dir*90;
    }
}