package sea.backend;

import sea.Vector2;
using sea.Vector2Utils;
import sea.Order;
import sea.backend.Ship;

class Server {

    public var tiles : Array< Array<Tile> >;

    public var width : Int;
    public var height : Int;

    public var players = 1;

    var ships : Array<Ship>;

    var processedPlayers = 0;

    public function new (width,height : Int) {

        this.width = width;
        this.height = height;
        tiles = new Array< Array<Tile>> ();
        for (i in 0...height) {
            var arr = new Array<> ();
            for (j in 0...width) {
                //arr.push (new Tile());
            }
            tiles.push(arr);
        }

        generateWorld();

        trace ("Done creating world");
    }


    public function processTurn (turn : PlayerTurn) {
        
        for (ship in turn.ships) {
            if (ship.entityIndex < 0 || ship.entityIndex >= ships.length) {
                throw "IndexOutOfRange";
            }

            if (ships[ship.entityIndex].playerIndex != turn.playerIndex) {
                throw "InfiltrationException";
            }

            var serverShip = ships[ship.entityIndex];
            serverShip.orders = ship.orders;
        }

        processedPlayers++;

        if (processedPlayers == players) {
            processAllMoves ();
            processedPlayers = 0;
        }
    }

    static public inline var TIMESTEPS = 8;

    private function processAllMoves () {
        var maxTime = 0;
        for (ship in ships) {
            maxTime = maxTime > ship.orders.length ? maxTime : ship.orders.length;
        }

        for (ship in ships) {
            ship.initTurn();
        }


        for (i in 0...maxTime) {

            for (ship in ships) {
                ship.beginOrder (i);
            }

            for (timestep in 0...TIMESTEPS) {
                trace ("--- TIMESTEP ---");
                //clearCollisionMarkers();

                for (ship in ships) {
                    var v = i >= ship.orders.length ? {type:OrderType.Idle} : ship.orders[i];
                    ship.simulateTime (i,timestep/(TIMESTEPS-1));
                    
                    //ship.checkCollision (v, timestep);
                }

                for (a in 0...ships.length) {
                    for (b in (a+1)...ships.length) {
                        ships[a].testCollision(ships[b], i, timestep/(TIMESTEPS-1));
                    }
                }
            }

            for (ship in ships) {
                var v = i >= ship.orders.length ? {type:OrderType.Idle} : ship.orders[i];
                ship.executeOrder (i);
            }
        }

        for (ship in ships) {
            ship.finalizeTurn ();
        }
    }

    public function getResult (playerIndex : Int) : ResultData {
        var filtered = new Array<Ship>();
        for (ship in ships) {
            if (ship.playerIndex == playerIndex) {
                filtered.push(ship);
            }
        }
        var res : ResultData = {ships: filtered};
        return res;
    }

    public function getWorld () : Array< Array< Tile >> {
        return tiles;
    }

    public function getTile (x,y : Int) : Tile {
        return tiles[y][x];
    }

    public function setTile (x,y : Int, tile : Tile) {
        tiles[y][x] = tile;
    }
    public function generateWorld () {

        ships = new Array<Ship>();

        setTile(Std.int(width/4), Std.int(height/2), new IslandTile());
        setTile(Std.int((3*width)/4), Std.int(height/2), new IslandTile());

        ships.push (new Ship (this, 0, ships.length, new Vector2(Std.int(width/4),Std.int(height/2)-1)));
        ships.push (new Ship (this, 0, ships.length, new Vector2(Std.int(width/4),Std.int(height/2)-2)));
    }
}

typedef ResultData = {
    ships : Array<Ship>
}

class PlayerTurn {
    public var playerIndex : Int;
    public var ships : Array<sea.Ship>;

    public function new () {}
}

class Tile {
    

}

class IslandTile extends Tile {
    public function new () {}
}
