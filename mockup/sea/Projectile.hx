package sea;

import sea.Ship;
import sea.Vector2;
import sea.Order;
using sea.Vector2Utils;

class Projectile extends Sprite {
    public var source : Ship;

    public var position : Vector2;
    public var dir : Vector2;
    public var speed = 10.0;

    public function new (source : Ship, dir : Vector2) {
        super ("projectile");
        this.source = source;
        this.dir = dir;
        position = source.position.copy();
    }

    public override function update () {
        position = position.add (dir.mult(speed*sea.Seabattle.deltaTime));

        var p = sea.Seabattle.worldToScreen(position);
        bitmap.x = p.x;
        bitmap.y = p.y;


    }
}