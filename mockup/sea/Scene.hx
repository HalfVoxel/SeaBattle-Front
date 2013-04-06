package sea;

import createjs.easeljs.Stage;
import createjs.easeljs.Bitmap;
import createjs.easeljs.SpriteSheet;
import createjs.easeljs.Shape;
import createjs.easeljs.Graphics;
import createjs.easeljs.Container;
import createjs.easeljs.DisplayObject;
import sea.Vector2;

class Scene {

    static var stage : Stage;

    static var worldLayers : Array<Container>;
    static var guiLayers : Array<Container>;
    static var worldContainer : Container;
    static var guiContainer : Container;

    public static function getWorldContainer () { return worldContainer; }

    public static function width () { return stage.canvas.width; }
    public static function height () { return stage.canvas.height; }

    public static function init (stage : Stage) {
        Scene.stage = stage;
        worldLayers = new Array<Container>();
        guiLayers = new Array<Container>();

        worldContainer = new Container();
        stage.addChild (worldContainer);

        guiContainer = new Container();
        stage.addChild (guiContainer);
    }

    public static function addToGUILayer (obj : DisplayObject, layer : Int) {
        if (layer > 255) throw "LotsOfLayersException";
        if (layer < 0) throw "NegativeLayerException";

        if (layer >= guiLayers.length) {
            for (i in guiLayers.length...(layer+1)) {
                guiLayers.push (new Container());
                guiContainer.addChild (guiLayers[i]);
            }
        }
        guiLayers[layer].addChild (obj);
    }

    public static function removeFromGUILayer (obj : DisplayObject, layer : Int) {
        if (layer > 255) throw "LotsOfLayersException";
        if (layer < 0) throw "NegativeLayerException";

        if (layer >= guiLayers.length) {
            throw "NoSuchLayerException";
        }

        if (!guiLayers[layer].removeChild (obj)) {
            throw "ChildNotInLayerException";
        }
    }

    public static function addToLayer (obj : DisplayObject, layer : Int) {
        if (layer > 255) throw "LotsOfLayersException";
        if (layer < 0) throw "NegativeLayerException";

        if (layer >= worldLayers.length) {
            for (i in worldLayers.length...(layer+1)) {
                worldLayers.push (new Container());
                worldContainer.addChild (worldLayers[i]);
            }
        }
        worldLayers[layer].addChild (obj);
    }

    public static function removeFromLayer (obj : DisplayObject, layer : Int) {
        if (layer > 255) throw "LotsOfLayersException";
        if (layer < 0) throw "NegativeLayerException";

        if (layer >= worldLayers.length) {
            throw "NoSuchLayerException";
        }

        if (!worldLayers[layer].removeChild (obj)) {
            throw "ChildNotInLayerException";
        }
    }
}