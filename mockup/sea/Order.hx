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
    ?completed : Bool,
    ?time : Float,
    ?endTime : Float, /** End time for certain events such as Fire: When the canonball hits the target (or water), currently relative, but should be absolute */
    ?chained : Order
}