package sea;

interface HasPosition {
    var position : Vector2;
}

/*typedef Vector2 = {
    var x : Float;
    var y : Float;
}*/

class Vector2 {
    public var x : Float;
    public var y : Float;

    public function copy () : Vector2 {
        return new Vector2(x, y);
    }

    public function add (b : Vector2) : Vector2 {
        return new Vector2(x+b.x, y+b.y);
    }

    public function sub (b : Vector2) : Vector2 {
        return new Vector2(x-b.x, y-b.y);
    }

    public function scale (b : Vector2) : Vector2 {
        return new Vector2(x*b.x, y*b.y);
    }

    public function mult (b : Float) : Vector2 {
        return new Vector2(x*b, y*b);
    }

    public function neg () {
        return new Vector2(-x, -y);
    }

    public function new (x,y : Float) {
        this.x = x;
        this.y = y;
    }
}