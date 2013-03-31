package sea;

class Island extends Sprite {

    public var position : Vector2;

    public function new (p : Vector2) {
        super ("island",2);

        position = p;
    }

    public override function update() {
        bitmap.x = position.x;
        bitmap.y = position.y;
    }
}