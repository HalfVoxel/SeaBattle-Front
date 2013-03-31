package sea;
import sea.Vector2;
import sea.Seabattle;
import sea.Order;
import sea.Projectile;

using sea.Vector2Utils;

import createjs.easeljs.Shape;
import createjs.easeljs.Stage;
import createjs.easeljs.Bitmap;
import createjs.easeljs.BitmapAnimation;
import createjs.easeljs.SpriteSheet;
import createjs.tweenjs.Ease;
import createjs.tweenjs.Tween;
import createjs.easeljs.Graphics;

class Ship implements HasPosition {
    public var position : Vector2;
    public var realPosition : Vector2;
    public var realDir : Int = 0;
    public var dir : Int = 0;
    public var angle : Float = 0;
    public var entityIndex : Int;

    var bmpAnimation : BitmapAnimation;

    static var spriteSheet : SpriteSheet;

    var pathShape : Shape;

    public var orders : Array<Order>;

    var time = 0.0;

    public var maxOrderCount = 4;

    public function new (entityIndex : Int) {
        this.entityIndex = entityIndex;
        position = new Vector2( 0,0);
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
        bmpAnimation.scaleX = bmpAnimation.scaleY = 1.0/Seabattle.PIXEL_DENSITY;

        // have each monster start at a specific frame
        bmpAnimation.currentAnimationFrame = cast Math.random()*spriteSheet.getNumFrames("idle");
        trace (Math.random()*spriteSheet.getNumFrames("idle"));
        //Seabattle.stage.addChild(bmpAnimation);
        sea.Scene.addToLayer(bmpAnimation, 3);
        bmpAnimation.addEventListener ("tick", update);

        pathShape = new Shape ();
        //Seabattle.stage.addChildAt(pathShape, 1);
        sea.Scene.addToLayer(pathShape,2);
    }

    public function endSimulation () {
        simulateTime(orders.length);
        untyped orders.length = 0;
        realPosition = position.copy();
        realDir = dir;
    }

    public function update () {
        bmpAnimation.x = position.x;
        bmpAnimation.y = position.y;
        bmpAnimation.rotation = angle+90;//dirToAngle(dir) + 90;
    }

    public function pushOrder (order : Order) : Bool {
        if (orders.length < maxOrderCount) {
            orders.push (order);
            //trace (order);
            
            updatePath ();
            return true;
        } else {
            return false;
        }
    }

    public function popOrder () {
        if (orders.length > 0) {
            orders.pop();
            updatePath ();
            return true;
        } else {
            return false;
        }
    }

    public function updatePath () {
        var g = pathShape.graphics;
        g.clear();

        g.setStrokeStyle(0.05,"round");
        g.beginStroke(Graphics.getRGB(17,69,117));
        //g.beginFill(Graphics.getRGB(255,0,0));
        //g.drawCircle(0,0,3);
        
        simulateTime(0);
        g.moveTo (position.x,position.y);
        //var prevDir = dir;
        for (i in 1...(orders.length+1)) {
            simulateTime(i);
            var p = position;
            var order = orders[i-1];
            if (order.type == OrderType.Move && order.dir != 2) {
                if (order.dir == 0) {
                    g.lineTo (p.x,p.y);
                } else {
                    var rotp = position.sub(Vector2Utils.dirToVector(dir));
                    g.arcTo (rotp.x, rotp.y, p.x,p.y, 1);
                }
            }
            //prevDir = dir;
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
                    position = position.add (Vector2Utils.dirToVector(dir));
                }
                dir = (dir+order.dir+4) % 4;
                position = position.add (Vector2Utils.dirToVector(dir));
            }
        }

        angle = dirToAngle(dir);

        t -= orderBase;
        if (t > 0.001) {
            var newPos = position.copy();
            var order = orders[orderBase];
            var newDir = dir;
            if (order.type == OrderType.Move) {
                if (order.dir != 0) {
                    newPos = newPos.add (Vector2Utils.dirToVector(newDir));
                }
                newDir = (newDir+order.dir+4) % 4;
                newPos = newPos.add (Vector2Utils.dirToVector(dir));

                if (order.dir == 0) {
                    position = Vector2Utils.lerp (position, newPos, t);
                } else {
                    //Turning required
                    var rotPos = position.add(Vector2Utils.dirToVector(newDir));
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
    }

    public function progressTime (time : Float) {
        simulateTime(time);
        var orderBase = Math.floor (time);
        orderBase = orderBase > orders.length-1 ? orders.length-1 : orderBase;
        orderBase = orderBase < 0 ? 0 : orderBase;

        if (orders.length > 0) {
            var order = orders[orderBase];
            if (!order.executed) {
                order.executed = true;
                
                if (order.type == OrderType.Fire) {
                    trace ("Executing Order " + order.type + " " + orderBase);
                    new Projectile (this, Vector2Utils.dirToVector((order.dir+dir+4) % 4));
                }
            }
        }
    }

    function dirToAngle (dir : Float) {
        return dir*90;
    }
}