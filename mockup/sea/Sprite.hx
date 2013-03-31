package sea;
import sea.Vector2;
import sea.Scene;

class Sprite {

    var bitmap : createjs.easeljs.Bitmap;

    public function new (spriteName : String, layer : Int) {
        bitmap = new createjs.easeljs.Bitmap(sea.Seabattle.getAsset(spriteName));
        bitmap.regX = bitmap.image.width/2;
        bitmap.regY = bitmap.image.height/2;
        bitmap.scaleX = bitmap.scaleY = 1.0/Seabattle.PIXEL_DENSITY;
        Scene.addToLayer(bitmap,layer);
        //sea.Seabattle.stage.addChildAt (bitmap,5);

        bitmap.addEventListener("tick", update);
    }

    public function visible (vis : Bool) {
        bitmap.visible = vis;
    }

    public function update () {
    }
}