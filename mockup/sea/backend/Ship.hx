package sea.backend;

import sea.Vector2;
import sea.Order;
import sea.backend.Server;

class Ship {
    public var position : Vector2;
    public var dir : Int;
    public var server : Server;

    public var orders : Array<Order>;
    public var orderResult : Array<Order>;

    public var destroyed : Int;
    public var playerIndex : Int;
    public var entityIndex : Int;

    public function new (server : Server, playerIndex : Int, entityIndex : Int, ?initPos : Vector2) {
        destroyed = 0;
        this.server = server;
        this.playerIndex = playerIndex;
        this.entityIndex = entityIndex;
        position = initPos == null ? new Vector2(0,0) : initPos;
        dir = 0;
        orders = new Array<Order>();
    }

    public function initTurn () {
        orderResult = new Array<Order>();
    }

    public function finalizeTurn () {
        orders = orderResult;
    }

    public function checkCollision (order : Order, timestep : Int) {
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

    public function executeOrder (order : Order) {
        if (destroyed <= 1) {
            server.getMove(this,order).execute(this);
            orderResult.push (order);
        }
        if (destroyed != 0) destroyed++;
    }

    public function onCollision (other : Ship, timestep : Int) {
        trace ("Ship " + entityIndex + " collided with " + other.entityIndex);

        //Push collision order
        orderResult.push ({type: OrderType.Collide, time: (timestep/2.0)});

        //Prevents further simulation of this ship
        destroyed++;
    }
}