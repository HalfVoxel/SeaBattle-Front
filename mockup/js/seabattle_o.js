/*jslint browser: true*/
/*global $, jQuery, Kinetic, createjs */

"use strict";

var tween = createjs.Tween;

var Input = {
    _pressed: {},

    LEFT: 37,
    UP: 38,
    RIGHT: 39,
    DOWN: 40,

    isDown: function (keyCode) {
        return this._pressed[keyCode];
    },
    
    onKeydown: function (event) {
        this._pressed[event.keyCode] = true;
    },
    
    onKeyup: function (event) {
        delete this._pressed[event.keyCode];
    }
};
    
window.addEventListener('keyup', function(event) { Input.onKeyup(event); }, false);
window.addEventListener('keydown', function(event) { Input.onKeydown(event); }, false);


function Ship(name) {
    
    if (name === undefined) { throw "Name is undefined"; }
    
    if (Ship.spriteSheet === undefined) {
        // create spritesheet and assign the associated data.
        Ship.spriteSheet = new createjs.SpriteSheet({
            // image to use
            images: ["assets/ship.png"], 
            // width, height & registration point of each sprite
            frames: {width: 64, height: 64, regX: 0, regY: 0, count: 64}, 
            animations: {    
                walk: [0, 0, "idle"]
            }
        });
    }
    
    this.x = 0;
    this.y = 0;
    this.dir = 0;
    
    // create a BitmapAnimation instance to display and play back the sprite sheet:
    var bmpAnimation = this.bmpAnimation = new createjs.BitmapAnimation(Ship.spriteSheet);
    
    // start playing the first sequence:
    bmpAnimation.gotoAndPlay("idle");     //animate
    
    // set up a shadow. Note that shadows are ridiculously expensive. You could display hundreds
    // of animated rats if you disabled the shadow.
    //bmpAnimation.shadow = new createjs.Shadow("#454", 0, 5, 4);
    
    bmpAnimation.name = name;
    bmpAnimation.direction = 90;
    bmpAnimation.vX = 4;
    bmpAnimation.x = 16;
    bmpAnimation.y = 32;
    
    // have each monster start at a specific frame
    bmpAnimation.currentFrame = 0;
    sea.stage.addChild(bmpAnimation);
}

Ship.prototype.move = function (dx, dy) {
    if (Math.abs(dx) > 1 || Math.abs(dy) > 1) {
        throw "DX or DY is greater than 1. Not supported";
    }
    
    tween.get(this).to({x: this.x + dx, y: this.y + dy}, 100, createjs.Ease.easeInOut);
    
    //this.bmpAnimation.x += dx * sea.deltaTime;
    //this.bmpAnimation.y += dy * sea.deltaTime;
}

Ship.prototype.keyOrder = function (event) {
    var key = event.which;
    console.log ("Got key " + key);
    
    //console.log (+'a');
    switch(key){
        case 'a'.charCodeAt():
        //case 'A'.charCodeAt():
            this.move (-1,0);
            break;
        case 'w'.charCodeAt():
            this.move (1,0);
    }
}

Ship.prototype.update = function () {
    var p = sea.worldToScreen(this);
    this.bmpAnimation.x = p.x;
    this.bmpAnimation.y = p.y;
};

var sea = {
    scale: 64,
    initCanvas: function () {
        
        //find canvas and load images, wait for last image to load
        this.canvaswr = $("#gameCanvas");
        
        //check for canvas support
        if (!(!!document.createElement('canvas').getContext)) {
            ////document.createElement("article");
            this.canvaswr.html("<div>" +
                "It appears you are using a browser that does not support " +
                "the HTML5 Canvas Element</div>");
    
                //canvas isnt support, so dont continue
            return;
        }
        
        var canvas = this.canvaswr.get(0);
            
        this.updateCanvasDimensions ();
        
        this.stage = new createjs.Stage(canvas);
        this.stage.enableDOMEvents(true);
        this.stage.enableMouseOver(10);
        
        
        
        
        this.ships = [];
        this.ships[0] = new Ship ("Ship5");
        
        var ship = this.ships[0];
        $(window).keypress(function() { ship.keyOrder });
        
        createjs.Ticker.addListener(this);
        createjs.Ticker.useRAF = true;
        // Best Framerate targeted (60 FPS)
        createjs.Ticker.setFPS(60);
        this.prevTime = new Date().getTime();
    },
    tick: function () {
        //console.log ("TICK");
        var ctime = new Date().getTime();
        this.deltaTime = (ctime - this.prevTime) * 0.001;
        this.prevTime = ctime;
        //console.log (this.deltaTime);
        
        //var dx = (Input.isDown(Input.UP)?30:0) + (Input.isDown(Input.DOWN)?-30:0);
        
        //this.ships["Ship5"].move (dx,0);
        var i = this.ships.length;
        while (i--) {
            this.ships[i].update();
        }
        
        this.stage.update();
    },
    //function that updates the size of the canvas based on the window size
    updateCanvasDimensions: function () {
        //note that changing the canvas dimensions clears the canvas.
        this.canvaswr.attr("height", $(window).height(true));
        this.canvaswr.attr("width", $(window).width(true));
    
        //save the canvas offset
        var canvasOffset = this.canvaswr.offset();	
    
        //if we have an overlay canvas
        /*if(canvasOverlayWrapper)
        {
            //resize it
            canvasOverlayWrapper.attr("height", $(window).height(true));
            canvasOverlayWrapper.attr("width", $(window).width(true));
            canvasOverlayOffset = canvasOverlayWrapper.offset();
        }*/	
    },
    /** Convert a world position to screen point */
    worldToScreen: function (p) {
        return {x: p.x * this.scale, y: p.y * this.scale};
    }
    
};


$(document).ready(function () {
    sea.initCanvas();
    
});
