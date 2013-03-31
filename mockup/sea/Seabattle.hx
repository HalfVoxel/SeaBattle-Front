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
    public static var offset = new Vector2( 1, 1);

    public static var selectedShip = 0;

    public static var targetTime : Int = 0;
    public static var time : Float = 0;

    static var server = new sea.backend.Server (30,15);

    static var canvas : Dynamic;

    static var assets : Hash<Dynamic>;

    static var loader : LoadQueue;
    static var marker : sea.Marker;

    static var prevTime : Float = 0;
    public static var deltaTime : Float = 1/60.0;

    public static var playerTurn = true;

    static public inline var PIXEL_DENSITY = 64;

    static var timeScale = 1000;

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

        canvas = new js.JQuery("#gameCanvas");

        //canvas.width = new js.JQuery("document").width();
        //canvas.height = new js.JQuery("document").height();
        //new js.JQuery("window").bind("resize",resize);

        //trace (canvas);

        //trace("Width " + canvas.get(0).width + " " + canvas.get(0).height);

        stage = new Stage(canvas.get(0));
        stage.canvas.width = js.Lib.window.innerWidth;
        stage.canvas.height = js.Lib.window.innerHeight;

        sea.Scene.init (stage);

        assets = new Hash<Dynamic> ();

        var manifest = [
            {src:"assets/ship.png", id:"ship"},
            {src:"assets/water.png", id:"water"},
            {src:"assets/marker.png", id:"marker"},
            {src:"assets/island.png", id:"island"},
            {src:"assets/projectile.png", id:"projectile"}
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

        /*for (i in 0...5) {
            s = new Ship(i+3);
            s.position = s.realPosition = new Vector2( 0, i+3);
            ships.push (s);
        }*/
        new js.JQuery(js.Lib.window).keydown(keyPress);

        

        var tiles = server.getWorld ();
        for (y in 0...tiles.length) {
            for (x in 0...tiles[y].length) {
                if (Std.is (tiles[y][x], sea.backend.Server.IslandTile)) {
                    var island : sea.backend.Server.IslandTile = cast tiles[y][x];
                    var isl = new sea.Island (new Vector2(x, y));        
                    trace ("Island " + x + " " + y);
                }
            }
        }

        /*for (i in 0...5) {
            var isl = new sea.Island (new Vector2( Std.int(Math.random()*12), Std.int (Math.random()*12)));
        }*/

        processResult ();

        marker = new sea.Marker (new Vector2( 0, 0));
        selectShip (0);
    }

    static function processResult () {
        var result = server.getResult (0);
        for (source in result.ships) {
            var s = null;
            for (ship in ships) {
                if (ship.entityIndex == source.entityIndex) {
                    s = ship;
                    break;
                }
            }

            if (s == null) {
                trace ("Creating new ship at " + source.position);
                s = new Ship (source.entityIndex);
                s.realPosition = source.position.copy();
                s.realDir = source.dir;
                ships.push(s);
            }
            s.orders = source.orders;
        }
    }
    static function handleFileLoad(event) {
        assets.set(event.item.id, event.item);
    }

    static function keyPress (event : js.JQuery.JqEvent) {
        //trace("Key " + event.which);
        var key = event.which;
        //To lowercase
        if (key >= 65 && key <= 90) key += 97 - 65;

        trace ("Key " + event.which + " : " + event.charCode);

        if (event.metaKey) return;

        switch (key) {
            case 'i'.code:
                offset.y += scale;
                trace (offset.y);
                return;
            case 'k'.code:
                offset.y -= scale;
                return;
            case 'l'.code:
                offset.x -= scale;
                return;
            case 'j'.code:
                offset.x += scale;
                return;
        }

        //Cannot do anything
        if (!playerTurn) return;

        if (selectedShip >= 0 && selectedShip < ships.length) {
            var ship = ships[selectedShip];
            var dir = -2;
            switch (key) {
                case 'a'.code:
                    dir = -1;
                case 'd'.code:
                    dir = 1;
                case 'w'.code:
                    dir = 0;
                case 's'.code:
                    dir = 2;
                case 'f'.code:
                    if (ship.popOrder()) {
                        targetTime = targetTime-1;
                        createjs.tweenjs.Tween.removeTweens(Seabattle);
                        createjs.tweenjs.Tween.get(Seabattle).to({time: targetTime}, 100);
                    }

                    event.preventDefault ();
                    return;
                case 'e'.code:
                    dir = 1;
                    ship.pushOrder({type: OrderType.Fire, dir: dir});
                    return;
                case 'q'.code:
                    dir = -1;
                    ship.pushOrder({type: OrderType.Fire, dir: dir});
                    return;
                case 'r'.code:
                    selectShip ((selectedShip+(event.shiftKey?-1:1) + ships.length) % ships.length);
                    targetTime = ships[selectedShip].orders.length;
                    createjs.tweenjs.Tween.removeTweens(Seabattle);
                    createjs.tweenjs.Tween.get(Seabattle).to({time: targetTime}, 100);

                    event.preventDefault ();
                    return;
                case ' '.code:
                    turnOver ();
                default:
                    return;
            }

            event.preventDefault ();

            if (dir != -2) {
                if (ship.pushOrder ({type: OrderType.Move, dir: dir})) {
                    targetTime = targetTime+1;
                    createjs.tweenjs.Tween.removeTweens(Seabattle);
                    createjs.tweenjs.Tween.get(Seabattle).to({time: targetTime}, 100);
                }
            }

        }
        //$(window).keypress(function() { ship.keyOrder });
    }

    static function turnOver () {
        playerTurn = false;

        var turn : sea.backend.Server.PlayerTurn = new sea.backend.Server.PlayerTurn();
        turn.playerIndex =  0;
        turn.ships = ships;

        server.processTurn (turn);
        processResult();
        simulateMoves ();
    }

    static function simulateMoves () {
        if (playerTurn) throw "InvalidGameState: Player turn when simulating moves.";

        var maxOrders = 0;
        for (i in 0...ships.length) {
            maxOrders = cast Math.max (maxOrders, ships[i].orders.length);
        }

        createjs.tweenjs.Tween.removeTweens(Seabattle);
        targetTime = maxOrders;
        time = 0;
        var tw1 = createjs.tweenjs.Tween.get(Seabattle);
        var tw = tw1.to({time: targetTime}, maxOrders*timeScale);
        tw.call (endSimulation);
        untyped tw.addEventListener ("change", progressTime);

    }

    static function progressTime () {
        for (i in 0...ships.length) {
            ships[i].progressTime(time);
        }
    }

    static function endSimulation () {
        for (i in 0...ships.length) {
            ships[i].endSimulation ();
        }
        time = 0;
        targetTime = 0;
        playerTurn = true;
    }

    static function tick () {
        var t = Date.now().getTime();
        deltaTime = (t-prevTime)*0.001;
        prevTime = t;

        for (ship in ships) { ship.simulateTime(time); }

        stage.scaleX = scale;
        stage.scaleY = scale;
        stage.x = offset.x;
        stage.y = offset.y;
        stage.update();
    }

    public static function worldToScreen (p : Vector2) {
        return p.copy();
        //return new Vector2( (p.x+offset.x)*scale, (p.y+offset.y)*scale);
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
        var p = worldToScreen(new Vector2(-2.5 + offset.x, -2.5));
        tiles.x = p.x;
        tiles.y = p.y;
        tiles.scaleX = tiles.scaleY = 1/64;

        //stage.addChildAt (tiles,0);
        sea.Scene.addToLayer (tiles, 0);
    }
}