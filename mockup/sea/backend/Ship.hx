package sea.backend;

import sea.Vector2;
import sea.Order;
import sea.backend.Server;
import sea.backend.Polygon;

class Ship {
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

    public var shape : Polygon;

    public function new (server : Server, playerIndex : Int, entityIndex : Int, ?initPos : Vector2) {
        destroyed = 0;
        this.server = server;
        this.playerIndex = playerIndex;
        this.entityIndex = entityIndex;
        position = initPos == null ? new Vector2(0,0) : initPos;
        dir = 0;
        orders = new Array<Order>();

        var verts = new Array<Vector2>();
        verts.push (new Vector2(-0.3,-0.4));
        verts.push (new Vector2( 0.3,-0.4));
        verts.push (new Vector2( 0.3, 0.4));
        verts.push (new Vector2(-0.3, 0.4));

        shape = new Polygon (verts);
    }

    public function initTurn () {
        orderResult = new Array<Order>();
    }

    public function finalizeTurn () {
        orders = orderResult;
    }

    public function beginOrder (orderIndex : Int) {
    }

    public function testCollision (other : Ship, orderIndex : Int, time : Float) {
        if (destroyed != 0) return;

        if (Polygon.intersects (shape,other.shape)) {
            //trace ("Collision");
            onCollision (other, orderIndex, time);
            other.onCollision (this, orderIndex, time);
        }
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
    public function executeOrder (orderIndex : Int) {
        if (destroyed < 1) {
            if (orderIndex < orders.length) {

                simulateTime (orderIndex, 1);
                position = simPosition.copy();
                dir = simDir;
                //server.getMove(this,order).execute(this);
                orderResult.push (orders[orderIndex]);
            } else {
                var v = {type:OrderType.Idle};
                orderResult.push(v);
            }
        }
        if (destroyed != 0) destroyed++;
    }

    public function onCollision (other : Ship, orderIndex : Int, time : Float) {
        trace ("Ship " + entityIndex + " collided with " + other.entityIndex + " at " + time);

        //Push collision order
        
        var od : Order = {type: OrderType.Collide, time: time};

        if (orderIndex < orders.length) {
            od.chained = orders[orderIndex];
            trace (orders[orderIndex]);
        }
        orderResult.push (od);

        //Prevents further simulation of this ship
        destroyed++;
    }

    static function dirToAngle (dir : Float) {
        return dir*90;
    }
}