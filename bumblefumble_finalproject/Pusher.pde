class Pusher {
  //Fields --------------------------------------------------------------------------------//
  PImage pusher_img;
  PShape pusher_rect;
  
  //Constructor ---------------------------------------------------------------------------//
  Pusher(PImage _pusher_img, PShape _pusher_rect) {
    pusher_img = _pusher_img;
    pusher_rect = _pusher_rect;
  }
  
  //Method: Displays the pusher -----------------------------------------------------------//
  void display() {
    imageMode(CORNER);
    image(pusher_img, pusher_rect.getVertexX(0), pusher_rect.getVertexY(0));
  }
}
