package sea.backend;

import sea.Vector2;
using sea.Vector2Utils;

class Move {
    public var relEnd : Vector2;
    public var collision : Array< Array< Vector2> >;
    public var validator : Dynamic;
    public var dir : Int;
    public function new (end : Vector2, collision : Array < Array< Vector2> >, dir : Int) {
        relEnd = end;   
        this.collision = collision;
        this.dir = dir;
    }

    /*public function placeMarkers (source : Ship, timestep : Int) : Ship {
        var server = source.server;
        if (timestep < 0 || timestep >= collision.length) throw "Out Of Time Bounds Exception";

        var arr = collision[timestep];
        for (p in arr) {
            var v = server.tryPlaceCollisionMarker (source.position.mult(2).add(p), source);
            if (v != null) return v;
        }
        return null;
    }*/

    public function execute (ship : Ship) {
        ship.position = ship.position.add(relEnd);
        ship.dir = (ship.dir + dir + 4) % 4;
    }
}