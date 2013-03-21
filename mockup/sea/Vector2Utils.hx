package sea;
import sea.Vector2;

class Vector2Utils {
    public static function copy (p : Vector2) : Vector2 {
        return {x: p.x, y: p.y};
    }

    public static function add (a : Vector2, b : Vector2) : Vector2 {
        return {x: a.x+b.x, y: a.y+b.y};
    }

    public static function sub (a : Vector2, b : Vector2) : Vector2 {
        return {x: a.x-b.x, y: a.y-b.y};
    }

    public static function scale (a : Vector2, b : Vector2) : Vector2 {
        return {x: a.x*b.x, y: a.y*b.y};
    }

    public static function mult (a : Vector2, b : Float) : Vector2 {
        return {x: a.x*b, y: a.y*b};
    }

    public static function vectorFromAngle (a : Float) : Vector2 {
        return {x: Math.cos (a*2*Math.PI/360.0), y: Math.sin (a*2*Math.PI/360.0)};
    }

    public static function lerp (a : Vector2, b : Vector2, t : Float) : Vector2 {
        return {x: a.x + (b.x-a.x)*t, y: a.y + (b.y-a.y)*t};
    }
}