package sea.backend;

import sea.Vector2;
using sea.Vector2Utils;
import sea.Order;
import sea.backend.Ship;

class Server {

    public var tiles : Array< Array<Tile> >;

    public var width : Int;
    public var height : Int;

    public var players = 2;


    public var ships : Array<Ship>;

    public var collisionEntities : Array<Entity>;

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
                throw "IndexOutOfRange " + ship.entityIndex + "/"+ships.length;
            }

            if (ships[ship.entityIndex].playerIndex != turn.playerIndex) {
                //Screw security, this is a javascript server ffs
                //throw "InfiltrationException";
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

    public function hasSentResults () {
        for (ship in ships) ship.betweenTurnReset ();
    }

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

            for (ship in ships) {
                var v = i >= ship.orders.length ? {type:OrderType.Idle} : ship.orders[i];
                ship.executeOrder (i);
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
                        if (ships[a].alive() && ships[b].alive()) ships[a].testCollision(ships[b], timestep/(TIMESTEPS-1));
                    }

                    //Collision with tiles
                    for (arr in tiles) {
                        for (tile in arr) {
                            if (tile != null) ships[a].testCollision(tile, timestep/(TIMESTEPS-1));
                        }
                    }
                }
            }

            for (ship in ships) {
                ship.executeOrder2 (i);
            }

            for (ship in ships) {
                ship.executeOrder3 (i);
            }
        }


        for (ship in ships) {
            ship.finalizeTurn ();
        }
    }

    public function getResult (playerIndex : Int) : ResultData {
        var filtered = new Array<Ship>();
        for (ship in ships) {
            //if (ship.playerIndex == playerIndex) {
            if (ship.alive()) {
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

        setTile(Std.int(width/4), Std.int(height/2), new IslandTile(new Vector2(Std.int(width/4), Std.int(height/2))));
        setTile(Std.int((3*width)/4), Std.int(height/2), new IslandTile(new Vector2(Std.int((3*width)/4), Std.int(height/2))));

        setTile(Std.int(width/2), Std.int(height/2), new RockTile(new Vector2(Std.int(width/2), Std.int(height/2))));
        setTile(Std.int(width/2), Std.int(height/2+1), new RockTile(new Vector2(Std.int(width/2), Std.int(height/2+1))));

        ships.push (new Ship (this, 0, ships.length, new Vector2(Std.int(width/4),Std.int(height/2)-1)));
        ships.push (new Ship (this, 0, ships.length, new Vector2(Std.int(width/4),Std.int(height/2)-2)));

        ships.push (new Ship (this, 1, ships.length, new Vector2(Std.int(3*width/4),Std.int(height/2)-1)));
        ships.push (new Ship (this, 1, ships.length, new Vector2(Std.int(3*width/4),Std.int(height/2)-2)));
        //trace ("Created " + ships.length + " ships");
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

class Tile extends Entity {
    
}

class IslandTile extends Tile {
    public function new (pos : Vector2) {
        var arr = [new Vector2(-0.4,-0.4),new Vector2(0.4,-0.4),new Vector2(0.4,0.4),new Vector2(-0.4,0.4)];
        shape = new sea.backend.Polygon (arr);
        shape.center = pos.copy();
    }
}

class RockTile extends Tile {
    public function new (pos : Vector2) {
        var arr = [new Vector2(-0.4,-0.4),new Vector2(0.4,-0.4),new Vector2(0.4,0.4),new Vector2(-0.4,0.4)];
        shape = new sea.backend.Polygon (arr);
        shape.center = pos.copy();
    }
}
