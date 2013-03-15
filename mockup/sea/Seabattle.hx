package sea;
import sea.Ship;
import createjs.easeljs.Shape;
import createjs.easeljs.Stage;
import createjs.easeljs.Bitmap;
import createjs.easeljs.SpriteSheet;
import createjs.easeljs.Ticker;
import sea.Vector2;
import sea.Order;

class Seabattle {

    public static var ships = new Array<Ship>();
    public static var stage;

    public static var scale = 64;
    public static var offset = {x: 1, y: 1};

    public static var selectedShip = 0;

    public static var targetTime : Int = 0;
    public static var time : Float = 0;

    static function main () {
        trace ("Hello World 4");

        var canvas = new js.JQuery("#gameCanvas");
        stage = new Stage(canvas.get(0));

        stage.enableDOMEvents(true);
        stage.enableMouseOver(10);
        
        Ticker.addListener(tick);
        Ticker.useRAF = true;
        // Best Framerate targeted (60 FPS)
        Ticker.setFPS(60);
        var prevTime = Date.now().getTime();

        ships.push (new Ship());
        ships.push (new Ship());
        ships.push (new Ship());

        new js.JQuery(js.Lib.window).keypress(keyPress);
    }

    static function keyPress (event : js.JQuery.JqEvent) {
        trace("Key " + event.which);
        var key = event.which;

        if (selectedShip >= 0 && selectedShip < ships.length) {
            var ship = ships[selectedShip];
            var dir = -2;
            trace('a'.charCodeAt(0));
            switch (key) {
                case 'a'.charCodeAt(0):
                    dir = -1;
                case 'd'.charCodeAt(0):
                    dir = 1;
                case 'w'.charCodeAt(0):
                    dir = 0;
                case 's'.charCodeAt(0):
                    dir = 2;
                case 'r'.charCodeAt(0):
                    targetTime = 0;
                    time = 0;
                    selectedShip = (selectedShip+1) % ships.length;
                    return;

            }
            if (dir != -2) {
                ship.pushOrder ({type: OrderType.Move, dir: dir});
            }

            targetTime = targetTime+1;
            createjs.tweenjs.Tween.removeTweens(Seabattle);
            createjs.tweenjs.Tween.get(Seabattle).to({time: targetTime}, 100);
        }
        //$(window).keypress(function() { ship.keyOrder });
    }

    static function tick () {
        for (ship in ships) { ship.simulateTime(time); }

        for (ship in ships) { ship.update(); }


        stage.update();
    }

    public static function worldToScreen (p : Vector2) {
        return {x: (p.x+offset.x)*scale, y: (p.y+offset.y)*scale};
    }
}