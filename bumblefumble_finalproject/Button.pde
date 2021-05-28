class Button {
  //Fields --------------------------------------------------------------------------------//
  int x, y, w, h, c;
  String words;
  
  //Constructor ---------------------------------------------------------------------------//
  Button(int _x, int _y, int _w, int _h, int _c, String _words) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    c = _c;
    words = _words;
  }

  void display() {
    rectMode(CENTER);

    //Checks if mouse is hovering over button and recolors appropriately
    if (checkHover()) {
      fill(color(c+50));
    } else {
      fill(color(c));
    }

    //Draws rectangular button
    rect(x, y, w, h);
    fill(255);
    textSize(20);
    textAlign(CENTER);
    text(words, x, y+7);
  }

  //Method that checks if mouse is within button boundaries
  boolean checkHover() {
    if ((x-w/2 < mouseX) & (x+w/2 > mouseX) & (y-h/2 < mouseY) & (y+h/2 > mouseY)) {
      return true;
    } else {
      return false;
    }
  }
}
