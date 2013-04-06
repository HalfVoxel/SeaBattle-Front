package sea;

import createjs.easeljs.Text;
import sea.Scene;
import sea.Seabattle;

class StatusGUI {

    var playerNode : Text;

    public function new () {

        playerNode = new Text("","48px Arial","rgb(228,248,255)");
        //playerNode.outline = true;
        playerNode.alpha = 0.75;
        playerNode.textAlign = "center";
        playerNode.x = Scene.width()/2;
        playerNode.y = 20;
        Scene.addToGUILayer (playerNode, 1);
    }

    public function setPlayerTurn (playerTurn : Int) {
        if (Seabattle.players == playerTurn) {
            playerNode.text = "Simulating...";
        } else {
            playerNode.text = "Player "+(playerTurn+1)+"'s Turn";
        }
    }

}