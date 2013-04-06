package sea.backend;

import sea.backend.Polygon;

class Entity {
    public var shape : Polygon;

    public function isSolid () {
        return true;
    }

    public function testCollision (other : Entity, time : Float) {
        if (!isSolid() || !other.isSolid()) return;

        if (shape == null || other.shape == null) return;

        if (Polygon.intersects (shape,other.shape)) {
            //trace ("Collision");
            onCollision (other, time);
            other.onCollision (this, time);
        }
    }

    public function onCollision (other : Entity, time : Float) {
    }
}