package sea.backend;

import sea.Vector2;
using sea.Vector2Utils;
import sea.backend.Move;
import sea.Order;
import sea.backend.Ship;

class Server {

    public var tiles : Array< Array<Tile> >;
    public var collisionTiles : Array< Array<CollisionTile> >;

    public var width : Int;
    public var height : Int;

    public var moves : Array<Move>;
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


        moves = new Array<Move>();
        //Right move
        //moves.push( new Move (new Vector2(1,0), { {new Vector2(0,0),new Vector2(1,0),new Vector2(0,1),new Vector2(1,1)}, { new Vector2(1,0),new Vector2(1,1),new Vector2(2,0),new Vector2(2,1)}, {new Vector2(2,0),new Vector2(3,0),new Vector2(2,1),new Vector2(3,1)}  ));

        //Straight moves
        for (i in 0...4) {
            var from : Vector2 = new Vector2(0,0);
            var to : Vector2 = from.add (Vector2Utils.dirToVector(i));

            var arr = new Array<Vector2> ();
            var start = arr;
            var p = from;
            arr.push (new Vector2(p.x*2+0,p.y*2+0));
            arr.push (new Vector2(p.x*2+1,p.y*2+0));
            arr.push (new Vector2(p.x*2+0,p.y*2+1));
            arr.push (new Vector2(p.x*2+1,p.y*2+1));

            arr = new Array<Vector2> ();
            var mid = arr;
            p = from.lerp(to,0.5);
            arr.push (new Vector2(p.x*2+0,p.y*2+0));
            arr.push (new Vector2(p.x*2+1,p.y*2+0));
            arr.push (new Vector2(p.x*2+0,p.y*2+1));
            arr.push (new Vector2(p.x*2+1,p.y*2+1));

            arr = new Array<Vector2> ();
            var end = arr;
            p = to;
            arr.push (new Vector2(p.x*2+0,p.y*2+0));
            arr.push (new Vector2(p.x*2+1,p.y*2+0));
            arr.push (new Vector2(p.x*2+0,p.y*2+1));
            arr.push (new Vector2(p.x*2+1,p.y*2+1));

            moves.push (new Move (to, [start, mid, end], 0));
        }

        var gridOffsets : Array<Vector2> = [new Vector2(1,0),new Vector2(0,1),new Vector2(0,0),new Vector2(0,0)];

        //Turning
        for (i in 0...4) {
            for (dir in 0...2) {
                var d = (dir*2) - 1;

                var from : Vector2 = new Vector2(0,0);
                from = from.mult (2);
                var globalDir2 = (i+d+4) % 4;

                var dir1 : Vector2 = Vector2Utils.dirToVector(i).mult(2);
                var dir2 : Vector2 = Vector2Utils.dirToVector(globalDir2).mult(2);

                var arr = new Array<Vector2> ();
                var start = arr;
                var p = from;
                arr.push (new Vector2(p.x+0,p.y+0));
                arr.push (new Vector2(p.x+1,p.y+0));
                arr.push (new Vector2(p.x+0,p.y+1));
                arr.push (new Vector2(p.x+1,p.y+1));

                arr = new Array<Vector2> ();
                var mid = arr;

                if (moves.length == 4) {
                    trace ("Turn *4");
                    trace (d + " " + globalDir2);
                    trace (from  + " " + dir1 + " " + dir2 + " ");
                }
                p = from.copy();
                if (dir1.x > 0) {
                    arr.push (new Vector2(p.x+dir1.x,p.y+0));
                    arr.push (new Vector2(p.x+dir1.x,p.y+1));
                } else if (dir1.x < 0) {
                    arr.push (new Vector2(p.x,p.y+0));
                    arr.push (new Vector2(p.x,p.y+1));
                } else if (dir1.y > 0) {
                    arr.push (new Vector2(p.x+0,p.y+dir1.y));
                    arr.push (new Vector2(p.x+1,p.y+dir1.y));
                } else if (dir1.y < 0) {
                    arr.push (new Vector2(p.x+0,p.y));
                    arr.push (new Vector2(p.x+1,p.y));
                }

                arr.push(from.add(dir1).add(gridOffsets[i]).add(gridOffsets[globalDir2]));

                p = from.copy().add(dir1).add(dir2);
                dir2 = dir2.neg();
                if (dir2.x > 0) {
                    arr.push (new Vector2(p.x+dir2.x,p.y+0));
                    arr.push (new Vector2(p.x+dir2.x,p.y+1));
                } else if (dir2.x < 0) {
                    arr.push (new Vector2(p.x,p.y+0));
                    arr.push (new Vector2(p.x,p.y+1));
                } else if (dir2.y > 0) {
                    arr.push (new Vector2(p.x+0,p.y+dir2.y));
                    arr.push (new Vector2(p.x+1,p.y+dir2.y));
                } else if (dir2.y < 0) {
                    arr.push (new Vector2(p.x+0,p.y));
                    arr.push (new Vector2(p.x+1,p.y));
                }


                var arr = new Array<Vector2> ();
                var end = arr;
                p = from.add(dir1).add(dir2);
                arr.push (new Vector2(p.x+0,p.y+0));
                arr.push (new Vector2(p.x+1,p.y+0));
                arr.push (new Vector2(p.x+0,p.y+1));
                arr.push (new Vector2(p.x+1,p.y+1));

                moves.push (new Move (p.mult(0.5), [start, mid, end], d));
            }
        }

        //Idle move
        {
            var arr = new Array<Vector2> ();
            var p : Vector2 = new Vector2(0,0);
            arr.push (new Vector2(p.x*2+0,p.y*2+0));
            arr.push (new Vector2(p.x*2+1,p.y*2+0));
            arr.push (new Vector2(p.x*2+0,p.y*2+1));
            arr.push (new Vector2(p.x*2+1,p.y*2+1));
            moves.push (new Move (p,[arr,arr,arr], 0));
        }

        //180 Idle move
        {
            var arr = new Array<Vector2> ();
            var p : Vector2 = new Vector2(0,0);
            arr.push (new Vector2(p.x*2+0,p.y*2+0));
            arr.push (new Vector2(p.x*2+1,p.y*2+0));
            arr.push (new Vector2(p.x*2+0,p.y*2+1));
            arr.push (new Vector2(p.x*2+1,p.y*2+1));
            moves.push (new Move (p,[arr,arr,arr], 2));
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

    static public inline var TIMESTEPS = 3;

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

    /*public function tryPlaceCollisionMarker (p : Vector2, ref : Ship) : Ship {
        var x = Std.int(p.x);
        var y = Std.int(p.y);
        trace ("Placing Marker at " + x+','+y);
        if (collisionTiles[y][x].collisionMarker != null) { return collisionTiles[y][x].collisionMarker; }
        collisionTiles[y][x].collisionMarker = ref;
        return null;
    }

    function clearCollisionMarkers () {
        for (tilearr in collisionTiles) {
            for (tile in tilearr) {
                tile.collisionMarker = null;
            }
        }
    }*/

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

        collisionTiles = new Array< Array < CollisionTile > >();

        for (y in 0...width*2) {
            var arr = new Array<CollisionTile> ();
            for (x in 0...height*2) {
                arr.push(new CollisionTile());
            }
            collisionTiles.push (arr);
        }
    }

    public function getMove (ship : Ship, order : sea.Order ) : Move {
        if (order.type == OrderType.Idle) return moves[4+4*2];
        if (order.type != OrderType.Move) return null;

        //Idle
        if (order.dir == 2) {
            return moves[4+4*2+1];
        }

        if (order.dir == 0) {
            return moves[ship.dir];
        } else {
            trace ("Turn " + (4+ship.dir*2 + Std.int((order.dir+1)/2)));
            return moves[4+ship.dir*2 + Std.int((order.dir+1)/2)];
        }
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

class CollisionTile {
    public function new () {}
    public var collisionMarker : Ship;
}

class Tile {
    

}

class IslandTile extends Tile {
    public function new () {}
}
