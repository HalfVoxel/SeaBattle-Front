package sea;
import sea.Vector2;

class Sprite {

    var bitmap : createjs.easeljs.Bitmap;

    public function new (spriteName : String) {
        bitmap = new createjs.easeljs.Bitmap(sea.Seabattle.getAsset(spriteName));
        bitmap.regX = bitmap.image.width/2;
        bitmap.regY = bitmap.image.height/2;
        sea.Seabattle.stage.addChildAt (bitmap,5);

        bitmap.addEventListener("tick", update);
    }

    public function visible (vis : Bool) {
        bitmap.visible = vis;
    }

    public function update () {
    }
}