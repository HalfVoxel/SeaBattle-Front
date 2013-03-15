package sea;
import sea.Vector2;

enum OrderType {
    Move;
    Fire;
}

typedef Order = {
    type : OrderType,
    ?dir : Int
}