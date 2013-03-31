package sea;
import sea.Vector2;

enum OrderType {
    Move;
    Fire;
    Collide;
    Idle;
}

typedef Order = {
    type : OrderType,
    ?dir : Int,
    ?executed : Bool,
    ?time : Float
}