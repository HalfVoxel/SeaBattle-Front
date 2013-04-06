package sea.backend;

import sea.Vector2;
import sea.Order;
import sea.backend.Server;
import sea.backend.Polygon;

class Ship extends sea.backend.Entity {
    public var position : Vector2;
    public var dir : Int;
    public var server : Server;

    public var simPosition : Vector2;
    public var simAngle : Float;
    public var simDir : Int;

    public var orders : Array<Order>;
    public var orderResult : Array<Order>;

    public var destroyed : Int;
    public var playerIndex : Int;
    public var entityIndex : Int;

    public var ammunition : Int = 5;
    public var range : Int = 5;
    var aliveFlag = true;
    var aliveFlagTurn = true;

    public function new (server : Server, playerIndex : Int, entityIndex : Int, ?initPos : Vector2) {
        destroyed = 0;
        this.server = server;
        this.playerIndex = playerIndex;
        this.entityIndex = entityIndex;
        position = initPos == null ? new Vector2(0,0) : initPos;
        dir = 0;
        orders = new Array<Order>();

        var verts = new Array<Vector2>();
        verts.push (new Vector2(-0.13,-0.42));
        verts.push (new Vector2( 0.13,-0.42));
        verts.push (new Vector2( 0.13, 0.42));
        verts.push (new Vector2(-0.13, 0.42));

        shape = new Polygon (verts);

        yields = new Array<Dynamic>();
    }

    public function betweenTurnReset () {
        aliveFlagTurn = aliveFlag;
    }

    public function initTurn () {
        orderResult = new Array<Order>();
    }

    public function finalizeTurn () {
        orders = orderResult;
    }

    public function beginOrder (orderIndex : Int) {
    }

    public override function isSolid () {
        return alive();
    }

    public function simulateTime (orderIndex : Int, t : Float) {
        /*if (num == currentOrder) return;

        if (num < currentOrder) {

        }*/


        t = t < 0 ? 0 : t;
        t = t > 1 ? 1 : t;

        simPosition = position.copy();
        simAngle = dirToAngle(dir);
        simDir = dir;

        shape.center = simPosition.copy();
        shape.rotation = simAngle;

        //Nothing to do here
        if (orderIndex >= orders.length) return;

        //trace ("Simulating time " + t + " with base " + orderBase);

        if (t > 0.001) {
            var newPos = position.copy();
            var order = orders[orderIndex];
            var newDir = dir;
            if (order.type == OrderType.Move) {
                if (order.dir != 0) {
                    newPos = newPos.add (Vector2Utils.dirToVector(newDir));
                }
                newDir = (newDir+order.dir+4) % 4;
                newPos = newPos.add (Vector2Utils.dirToVector(dir));

                if (order.dir == 0) {
                    simPosition = Vector2Utils.lerp (position, newPos, t);
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
                        simPosition = rotPos.add (Vector2Utils.vectorFromAngle(ra));
                        simAngle = (aa + (ab-aa)*t) % 360;
                    } else {
                        //CCW
                        if (b > a) a += 360;
                        if (ab > aa) aa += 360;

                        var ra = (a + (b-a)*t) % 360;
                        simPosition = rotPos.add (Vector2Utils.vectorFromAngle(ra));
                        simAngle = (aa + (ab-aa)*t) % 360;
                    }
                }
            }

            simDir = newDir;
        }


        shape.center = simPosition.copy();
        shape.rotation = simAngle;
        trace (shape.center + " " + shape.rotation);
    }

    /*public function checkCollision (order : Order, timestep : Int) {
        if (destroyed != 0) { return; }


        var move = server.getMove (this,order);
        trace (move);
        trace (order.type);
        var colliding = move.placeMarkers(this, timestep);
        if (colliding != null) {
            onCollision (colliding, timestep);
            colliding.onCollision (this, timestep);
        } else {
        }
    }
*/

    public function alive () {
        return aliveFlagTurn;
    }

    public function executeOrder (orderIndex : Int) {
        if (destroyed < 1) {
            if (orderIndex >= orders.length) {
                orderResult.push ({type:OrderType.Idle});
                return;
            }

            
                //server.getMove(this,order).execute(this);
                
            //}

            var order = orders[orderIndex];
            switch (order.type) {
            case OrderType.Fire:
                var d = Vector2Utils.dirToVector((dir+order.dir+4)%4);
                var hit = false;
                for (i in 0...range) {
                    var p = d.mult(i+1).add(position);

                    for (ship in server.ships) {
                        if (ship.alive()) {
                            if (ship.position.sub(p).sqrMagnitude() < 0.1*0.1) {
                                //HIT
                                yield (function () {ship.onCollision(this, (i+1)/range);});
                                var o = orders[orderIndex];
                                o.endTime = (i+1)/range;
                                orderResult.push (o);
                                break;
                            }
                        }
                    }
                    if (hit) break;
                }
                if (!hit) orderResult.push (orders[orderIndex]);
            default:
                orderResult.push (orders[orderIndex]);
            }



        }
        if (destroyed != 0) destroyed++;
    }

    var yields : Array<Dynamic>;
    public function yield (fn : Dynamic) {
        yields.push(fn);
    }

    public function executeOrder2 (orderIndex : Int) {
        while(yields.length > 0) {
            yields.shift()();
        }

    }

    public function executeOrder3 (orderIndex : Int) {

        if (destroyed > 0) {
            aliveFlag = false;
            return;
        }

        if (orderIndex >= orders.length) return;

        simulateTime (orderIndex, 1);
        position = simPosition.copy();
        dir = simDir;

    }

    public override function onCollision (other : sea.backend.Entity, time : Float) {

        if (!alive()) throw "Collision with destroyed entity.";

        //Dont destroy twice same turn
        if (destroyed > 0) return;

        //trace ("Ship " + entityIndex + " collided with " + other.entityIndex + " at " + time);

        

        //Push collision order
        
        var od : Order = {type: OrderType.Collide, time: time};

        //if (orderIndex < orders.length) {
            od.chained = orderResult.pop();
            //trace ("CHAINING " + orders[orderIndex]);
        //} else {
            //od.chained = {type: OrderType.Idle};
        //}

        orderResult.push (od);

        //Prevents further simulation of this ship
        destroyed+=1;
    }

    static function dirToAngle (dir : Float) {
        return dir*90;
    }
}