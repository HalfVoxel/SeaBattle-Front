package sea;
import sea.Ship;
import createjs.easeljs.Shape;
import createjs.easeljs.Stage;
import createjs.easeljs.Bitmap;
import createjs.easeljs.SpriteSheet;
import createjs.easeljs.Ticker;
import createjs.easeljs.Shape;
import createjs.easeljs.Graphics;
import createjs.preloadjs.LoadQueue;
import sea.Vector2;
import sea.Order;
import js.Dom;

class Seabattle {

    public static var ships = new Array<Ship>();
    public static var stage;

    public static var scale = 64;
    public static var offset = {x: 1, y: 1};

    public static var selectedShip = 0;

    public static var targetTime : Int = 0;
    public static var time : Float = 0;

    static var canvas : Dynamic;

    static var assets : Hash<Dynamic>;

    static var loader : LoadQueue;
    static var marker : sea.Marker;

    static var prevTime : Float = 0;
    public static var deltaTime : Float = 1/60.0;

    public static function getAsset (id : String) : Dynamic {
        var a = loader.getResult(id);//assets.get(id);
        if (a == null) throw "Asset " + id + " has not been loaded";
        return a;
    }

    static function resize (event : js.JQuery.JqEvent) {
        var w = new js.JQuery("window").width();
        var h = new js.JQuery("window").height();
        trace ("width " + w);
        canvas.css("width", w + "px");
        canvas.css("height", h + "px");
    }

    static function selectShip (i : Int) {
        selectedShip = i;
        if (selectedShip >= 0 && selectedShip < ships.length) {
            marker.target = ships[selectedShip];
        }
    }

    static function main () {

        trace ("Hello World 4");

        canvas = new js.JQuery("#gameCanvas");

        //canvas.width = new js.JQuery("document").width();
        //canvas.height = new js.JQuery("document").height();
        //new js.JQuery("window").bind("resize",resize);

        //trace (canvas);

        //trace("Width " + canvas.get(0).width + " " + canvas.get(0).height);

        stage = new Stage(canvas.get(0));
        stage.canvas.width = js.Lib.window.innerWidth;
        stage.canvas.height = js.Lib.window.innerHeight;

        assets = new Hash<Dynamic> ();

        var manifest = [
            {src:"assets/ship.png", id:"ship"},
            {src:"assets/water.png", id:"water"},
            {src:"assets/marker.png", id:"marker"}
        ];

        loader = new LoadQueue(false);
        loader.onFileLoad = handleFileLoad;
        loader.onComplete = setup;
        loader.loadManifest(manifest);
        trace ("Loading...");
    }

    static function setup (e : Dynamic) {
        trace ("Loading Complete");
        setupBackground ();

        stage.enableDOMEvents(true);
        //stage.enableMouseOver(10);
        
        Ticker.addListener(tick);
        Ticker.useRAF = true;
        // Best Framerate targeted (60 FPS)
        Ticker.setFPS(60);
        var prevTime = Date.now().getTime();

        var s = new Ship();
        s.position = s.realPosition = {x: 0, y: 0};
        ships.push (s);

        s = new Ship();
        s.position = s.realPosition = {x: 0, y: 1};
        ships.push (s);

        s = new Ship();
        s.position = s.realPosition = {x: 0, y: 2};
        ships.push (s);

        for (i in 0...5) {
            s = new Ship();
            s.position = s.realPosition = {x: 0, y: i+3};
            ships.push (s);
        }
        new js.JQuery(js.Lib.window).keypress(keyPress);

        marker = new sea.Marker ({x: 5, y: 2});

        selectShip (0);
    }

    static function handleFileLoad(event) {
        assets.set(event.item.id, event.item);
    }

    static function keyPress (event : js.JQuery.JqEvent) {
        //trace("Key " + event.which);
        var key = event.which;

        event.preventDefault ();

        trace ("Key " + event.which + " : " + event.charCode);

        if (selectedShip >= 0 && selectedShip < ships.length) {
            var ship = ships[selectedShip];
            var dir = -2;
            switch (key) {
                case 'a'.charCodeAt(0):
                    dir = -1;
                case 'd'.charCodeAt(0):
                    dir = 1;
                case 'w'.charCodeAt(0):
                    dir = 0;
                case 's'.charCodeAt(0):
                    dir = 2;
                case 'f'.charCodeAt(0):
                    
                    if (ship.popOrder()) {
                        targetTime = targetTime-1;
                        createjs.tweenjs.Tween.removeTweens(Seabattle);
                        createjs.tweenjs.Tween.get(Seabattle).to({time: targetTime}, 100);
                    }
                    return;
                case 'r'.charCodeAt(0):
                    selectShip ((selectedShip+1) % ships.length);
                    targetTime = ships[selectedShip].orders.length;
                    createjs.tweenjs.Tween.removeTweens(Seabattle);
                    createjs.tweenjs.Tween.get(Seabattle).to({time: targetTime}, 100);
                    return;
                default:
                    return;
            }
            if (dir != -2) {
                ship.pushOrder ({type: OrderType.Move, dir: dir});
                targetTime = targetTime+1;
                createjs.tweenjs.Tween.removeTweens(Seabattle);
                createjs.tweenjs.Tween.get(Seabattle).to({time: targetTime}, 100);
            }

        }
        //$(window).keypress(function() { ship.keyOrder });
    }

    static function tick () {
        var t = Date.now().getTime();
        deltaTime = (t-prevTime)*0.001;
        prevTime = t;

        for (ship in ships) { ship.simulateTime(time); }

        for (ship in ships) { ship.update(); }


        stage.update();
    }

    public static function worldToScreen (p : Vector2) {
        return {x: (p.x+offset.x)*scale, y: (p.y+offset.y)*scale};
    }

    public static function setupBackground () {
        trace ("Loading Background");
        // create spritesheet and assign the associated data.
        /*var spriteSheet = new SpriteSheet({
            // image to use
            images: ["assets/water.png"], 
            // width, height & registration point of each sprite
            frames: {width: 512, height: 512, regX: 0, regY: 0, count: 1}, 
            animations: {    
                idle: [0, 0, "idle"]
            }
        });*/

        /*// create a BitmapAnimation instance to display and play back the sprite sheet:
        bmpAnimation = new BitmapAnimation(spriteSheet);
        
        // start playing the first sequence:
        bmpAnimation.gotoAndPlay("idle");     //animate
        
        // set up a shadow. Note that shadows are ridiculously expensive. You could display hundreds
        // of animated rats if you disabled the shadow.
        //bmpAnimation.shadow = new createjs.Shadow("#454", 0, 5, 4);
        
        bmpAnimation.name = "ShipAnim";
        bmpAnimation.x = 16;
        bmpAnimation.y = 32;
        
        // have each monster start at a specific frame
        bmpAnimation.currentFrame = 0;
        Seabattle.stage.addChild(bmpAnimation);*/

        var water = loader.getItem("water");
        if (water.type == LoadQueue.IMAGE) {
            var bmp = new Bitmap(loader.getResult("water"));
        }

        var tiles = new Shape(new Graphics().beginBitmapFill(loader.getResult("water")).drawRect(0,0,canvas.width()*2,canvas.height()*2));
        var p = worldToScreen({x:-2.5 + offset.x, y: -2.5});
        tiles.x = p.x;
        tiles.y = p.y;

        stage.addChildAt (tiles,0);
    }
}