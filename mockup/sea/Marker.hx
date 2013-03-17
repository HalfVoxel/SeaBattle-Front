package sea;

import sea.Vector2;
using sea.Vector2Utils;

class Marker {

    public var position : Vector2;

    public var target : HasPosition;

    var bitmap : createjs.easeljs.Bitmap;
    public function new (p : Vector2) {
        position = p;
        bitmap = new createjs.easeljs.Bitmap(sea.Seabattle.getAsset("marker"));
        bitmap.regX = bitmap.image.width/2;
        bitmap.regY = bitmap.image.height/2;
        sea.Seabattle.stage.addChildAt (bitmap,5);

        bitmap.addEventListener("tick", update);
    }

    public function visible (vis : Bool) {
        bitmap.visible = vis;
    }

    public function update () {
        if (target != null) position = target.position.copy();
        var p = sea.Seabattle.worldToScreen(position);
        bitmap.x = p.x;
        bitmap.y = p.y;
        bitmap.rotation += sea.Seabattle.deltaTime*20;
    }
}