package sea.backend;

using sea.Vector2;

class Polygon {

    public var center : Vector2;
    public var rotation = 0.0;
    public var vertices : Array<Vector2>;

    public function new (verts : Array<Vector2>) {
        this.vertices = verts;
        center = new Vector2(0,0);
    }

    static public inline var DEG2RAD = Math.PI*2/360;

    public function worldVertex (index : Int) {
        var forward = new Vector2 (Math.cos(rotation*DEG2RAD), Math.sin(rotation*DEG2RAD));
        var right = new Vector2 (forward.y, -forward.x);

        return forward.mult(vertices[index].y).add (right.mult(vertices[index].x)).add(center);
    }

    public static function intersects (a : Polygon, b : Polygon) {
        if (a.contains(b.worldVertex(0)) || b.contains(a.worldVertex(0))) {
            return true;
        }

        for (i in 0...a.vertices.length) {
            for (j in 0...b.vertices.length) {
                if (segmentsIntersect(a.worldVertex(i),a.worldVertex((i+1) % a.vertices.length), b.worldVertex(j),b.worldVertex((j+1) % b.vertices.length))) {
                    return true;
                }
            }
        }
        return false;
    }

    public function contains (p : Vector2) : Bool {
        var j = vertices.length-1;
        var inside = false; 
       
        for (i in 0...vertices.length) {
            if ( ((worldVertex(i).y <= p.y && p.y < worldVertex(j).y) || (worldVertex(j).y <= p.y && p.y < worldVertex(i).y)) && 
                (p.x < (worldVertex(j).x - worldVertex(i).x) * (p.y - worldVertex(i).y) / (worldVertex(j).y - worldVertex(i).y) + worldVertex(i).x)) {
                inside = !inside;
                j = i;
            }
        }
        return inside; 
    }

    /** Returns if the two line segments intersects. The lines are NOT treated as infinite (just for clarification)
     */
    public static function segmentsIntersect (start1 : Vector2, end1 : Vector2, start2 : Vector2, end2 : Vector2) : Bool {
        
        var dir1 = end1.sub(start1);
        var dir2 = end2.sub(start2);
        
        var den = dir2.y*dir1.x - dir2.x * dir1.y;
        
        if (den == 0.0) {
            return false;
        }
        
        var nom = dir2.x*(start1.y-start2.y)- dir2.y*(start1.x-start2.x);
        var nom2 = dir1.x*(start1.y-start2.y) - dir1.y * (start1.x - start2.x);
        var u = nom/den;
        var u2 = nom2/den;
    
        if (u < 0.0 || u > 1.0 || u2 < 0.0 || u2 > 1.0) {
            return false;
        }
        return true;
    }
}