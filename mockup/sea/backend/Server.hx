package sea.backend;

import sea.Vector2;

class Server {

    public tiles : Array< Array<Tile> >;

    public width : Int;
    public height : Int;

    public function new (width,height : Int) {
        this.width = width;
        this.height = height;
        tiles = new Array< Array<Tile> ();
        for (i in 0...height) {
            var arr = Array< Array<Tile> > ();
            for (j in 0...width) {
                arr.push (new Tile());
            }
            tiles.push(arr);
        }

        generateWorld();

        trace ("Done creating world");
    }

    public function getTile (x,y : Int) : Tile {
        return tiles[y][x];
    }

    public function generateWorld () {
        for (i in 0...width)
    }
}

class Tile {
    
}