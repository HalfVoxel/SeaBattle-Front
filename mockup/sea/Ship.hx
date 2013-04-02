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
        progressTime(orders.length);
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
        
        var dt = simulateTime(0);
        g.moveTo (dt.position.x,dt.position.y);
        //var prevDir = dir;
        
        var accTime = 0.0;
        for (order in orders) {
            accTime += order.time != null ? order.time : 1;
            dt = simulateTime(accTime);
            trace (dt);
            var p = dt.position;

            if (order.type == OrderType.Move && order.dir != 2) {
                if (order.dir == 0) {
                    g.lineTo (p.x,p.y);
                } else {
                    var rotp = p.sub(Vector2Utils.dirToVector(dt.dir));
                    g.arcTo (rotp.x, rotp.y, p.x,p.y, 1);
                }
            }
            //prevDir = dir;
        }
    }

    public function moveToSimulatedTime (t : Float) {
        var dt = simulateTime (t);
        position = dt.position;
        dir = dt.dir;
        angle = dt.angle;
    }

    /**
     * Simulate time. Assumes no complex orders, only move orders will be correctly simulated, other orders will be handled as Idle orders.
     * Also assumes that this is during the players turn, i.e the ship has not performed any events yet.
     * 
     * @param  t :             Float Time to simulate, from start of turn.
     */
    public function simulateTime (t : Float) {

        var cpos = realPosition.copy();
        var cangle = dirToAngle(realDir);
        var cdir = realDir;

        var accTime = 0.0;
        for (i in 0...orders.length) {
            var order = orders[i];

            var eventTime = order.time != null ? order.time : 1;

            var elapsedTime = t - accTime;
            elapsedTime = elapsedTime > eventTime ? eventTime : elapsedTime;

            if (accTime < t) {
                if (order.type == OrderType.Move) {
                    
                    var order = orders[i];
                    while (order.chained != null) {
                        trace ("Running chained order ");
                        order = order.chained;
                    }

                    var newDir = cdir;
                    var newPos = cpos.copy();

                    if (order.type == OrderType.Move) {
                        if (order.dir != 0) {
                            newPos = newPos.add (Vector2Utils.dirToVector(newDir));
                        }
                        newDir = (newDir+order.dir+4) % 4;
                        newPos = newPos.add (Vector2Utils.dirToVector(cdir));

                        if (order.dir == 0) {
                            cpos = Vector2Utils.lerp (cpos, newPos, elapsedTime);
                        } else {
                            //Turning required
                            var rotPos = cpos.add(Vector2Utils.dirToVector(newDir));
                            var a = dirToAngle ((newDir+2) % 4);
                            var b = dirToAngle (cdir);

                            var aa = dirToAngle (cdir);
                            var ab = dirToAngle (newDir);

                            if (order.dir == 1) {
                                //CW
                                if (b < a) b += 360;
                                if (ab < aa) ab += 360;

                                var ra = (a + (b-a)*elapsedTime) % 360;
                                cpos = rotPos.add (Vector2Utils.vectorFromAngle(ra));
                                cangle = (aa + (ab-aa)*elapsedTime) % 360;
                            } else {
                                //CCW
                                if (b > a) a += 360;
                                if (ab > aa) aa += 360;

                                var ra = (a + (b-a)*elapsedTime) % 360;
                                cpos = rotPos.add (Vector2Utils.vectorFromAngle(ra));
                                cangle = (aa + (ab-aa)*elapsedTime) % 360;
                            }
                        }
                    }

                    cdir = newDir;
                }
            }


            accTime += eventTime;
        }

        return {position: cpos, dir: cdir, angle: cangle};
    }

    public function progressTime (time : Float) {
        //var orderBase = Math.floor (time);

        //orderBase = orderBase > orders.length-1 ? orders.length-1 : orderBase;
        //orderBase = orderBase < 0 ? 0 : orderBase;

        var accTime = 0.0;
        for (i in 0...orders.length) {
            var t = orders[i].time != null ? orders[i].time : 1;
            
            if (!orders[i].executed) {
                beginEvent (orders[i], accTime);
            }

            if (accTime+t > time) {
                simulateEvent (orders[i], time - accTime);
                break;
            } else {
                if (!orders[i].completed) {
                    completeEvent (orders[i]);
                }
            }
            accTime += t;
        }
        

        /*if (orders.length > 0) {

            var order = orders[orderBase];
            if (!order.executed) {
                if (order.type == OrderType.Fire) {
                    order.executed = true;
                    trace ("Executing Order " + order.type + " " + orderBase);
                    new Projectile (this, Vector2Utils.dirToVector((order.dir+dir+4) % 4));
                }

                if (order.type == OrderType.Collide && (time - orderBase) >= order.time) {
                    order.executed = true;
                    new sea.Island (position.copy());
                }
            }

            if (order.type == OrderType.Collide) {

                //Skip this order
                //time = time + 1;
            }
        }

        simulateTime(time);*/
    }

    function beginEvent (event : Order, time : Float) {
        if (event.executed) return;
        event.executed = true;

        trace ("Begun " + event.type);

        switch (event.type) {
        case OrderType.Fire:
            new Projectile (this, event, time);
        default:
        }
    }

    /**
     * Called when an event is completed.
     * Should make sure that the object is at the correct state as if the simulateEvent function would have been run all the way to the end exactly
     * and call any eventual effects at the end of the event.
     * 
     * @param  event :             Order Order to complete
     */
    function completeEvent (event : Order) {
        if (event.completed) return;
        event.completed = true;

        trace ("Completed " + event.type);

        switch (event.type) {
        case OrderType.Move:
            //Make up for a non continous simulation and simulate the event at end time
            simulateEvent (event, 1);

            realPosition = position.copy();

            //Switch direction
            dir = (dir + event.dir + 4) % 4;
            realDir = dir;
        default:
        }
    }

    /**
     * Simulate an event at time t after the event started.
     * @param  event :             Order Event to simulate
     * @param  t     :             Float Time relative to the start of the event
     */
    function simulateEvent (event : Order, t : Float) {

        //trace ("Simulting... " + event.type + " " + t);

        switch (event.type) {
        case OrderType.Move:

            position = realPosition.copy();
            dir = realDir;
            angle = dirToAngle (dir);

            var newPos = position.copy();
            var order = event;

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
        default:
        }
    }

    function dirToAngle (dir : Float) {
        return dir*90;
    }
}