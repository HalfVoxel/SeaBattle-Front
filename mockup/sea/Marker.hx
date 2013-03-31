package sea;

import sea.Vector2;
using sea.Vector2Utils;

class Marker extends Sprite {

    public var position : Vector2;

    public var target : HasPosition;

    public function new (p : Vector2) {
        position = p;
        super("marker",5);
    }

    public override function update () {
        if (target != null) position = target.position.copy();
        
        bitmap.x = position.x;
        bitmap.y = position.y;
        bitmap.rotation += sea.Seabattle.deltaTime*20;
    }
}