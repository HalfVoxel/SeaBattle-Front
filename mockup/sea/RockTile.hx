package sea;

import createjs.easeljs.SpriteSheet;

class RockTile extends Effect {

    static var spriteSheet : SpriteSheet;

    public function new (p : Vector2) {

        if (spriteSheet == null) {
            // create spritesheet and assign the associated data.
            spriteSheet = new SpriteSheet({
                // image to use
                images: ["assets/rocks.png"], 
                // width, height & registration point of each sprite
                frames: {width: 64, height: 64, regX: 32, regY: 32, count: 5}, 
                animations: {
                    idle: [0, 5, "idle",4]
                }
            });
        }
        super (spriteSheet,2);

        position = p;
        rotation = Std.int(Math.random()*4)*90;
    }
}