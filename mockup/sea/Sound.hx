package sea;

import createjs.soundjs.Sound;


class Sound {
    
    static var playing = new Hash<String>();


    public static function play (id : String, volume=1.0) {
        if (playing.exists(id)) return;
        playing.set(id,id);
        var inst = createjs.soundjs.Sound.play (id);
        untyped inst.addEventListener ("complete", function (event : Dynamic) { playing.remove(id); });

        inst.setVolume (volume);

    }

    static function completePlay (event : Dynamic) {
        trace (event);
    }
}