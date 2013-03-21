package sea;

class Island {

    public var position : Vector2;

    var bitmap : createjs.easeljs.Bitmap;

    public function new (p : Vector2) {
        position = p;

        bitmap = new createjs.easeljs.Bitmap(sea.Seabattle.getAsset("island"));
        bitmap.regX = bitmap.image.width/2;
        bitmap.regY = bitmap.image.height/2;
        sea.Seabattle.stage.addChildAt (bitmap,6);

        //bitmap.addEventListener("tick", update);
        update();
    }

    public function update() {
        var p = sea.Seabattle.worldToScreen(position);
        bitmap.x = p.x;
        bitmap.y = p.y;
    }
}