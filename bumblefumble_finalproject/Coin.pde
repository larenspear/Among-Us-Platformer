class Coin {
  //Fields --------------------------------------------------------------------------------//
  PImage[] coin_frames;
  PShape coin_rect;
  boolean collected = false;
  
  //Constructor ---------------------------------------------------------------------------//
  Coin(PImage[] _coin_frames, PShape _coin_rect) {
    coin_frames = _coin_frames;
    coin_rect = _coin_rect;
  }
  
  //Method: Displays the coin if it hasn't been collected ---------------------------------//
  void display(int current_coin_frame) {
    if (!collected) {
      imageMode(CENTER);
      image(coin_frames[current_coin_frame], coin_rect.getVertexX(0), coin_rect.getVertexY(0));
    }
  }
}
