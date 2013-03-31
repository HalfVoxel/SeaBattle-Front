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

    static var layers : Array<Container>;

    public static function init (stage : Stage) {
        Scene.stage = stage;
        layers = new Array<Container>();
    }

    public static function addToLayer (obj : DisplayObject, layer : Int) {
        if (layer > 255) throw "LotsOfLayersException";
        if (layer < 0) throw "NegativeLayerException";

        if (layer >= layers.length) {
            for (i in layers.length...(layer+1)) {
                layers.push (new Container());
                stage.addChild (layers[i]);
            }
        }
        layers[layer].addChild (obj);
    }
}