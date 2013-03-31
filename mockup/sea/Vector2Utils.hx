package sea;
import sea.Vector2;

class Vector2Utils {

    public static function vectorFromAngle (a : Float) : Vector2 {
        return new Vector2(Math.cos (a*2*Math.PI/360.0), Math.sin (a*2*Math.PI/360.0));
    }

    public static function lerp (a : Vector2, b : Vector2, t : Float) : Vector2 {
        return new Vector2(a.x + (b.x-a.x)*t, a.y + (b.y-a.y)*t);
    }

    static var dirVectors : Array<Vector2> = [new Vector2(1,0),new Vector2(0,1),new Vector2(-1,0),new Vector2(0,-1)];
    public static function dirToVector (dir : Int) {
        return dirVectors[dir];
    }
}