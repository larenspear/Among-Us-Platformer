class Bird {
  float x1, y1, theta1, theta2, theta3, x_trans, y_trans;
  PVector speed;
  PShape star1, star2, star3;
  PImage bird;

  Bird(float x1, float y1, PVector speed) {
    this.x1 = x1;
    this.y1 = y1;
    this.speed = speed;
    
    bird = loadImage("screen/bird.png");
    
    //Create star1
    fill(#ffdb58 );
    float angle = TWO_PI / 5;
    float halfAngle = angle/2.0;
    //star1 = createShape();
    //star1.beginShape();
    //for (float a = 0; a < TWO_PI; a += angle) {
    //  float sx = x1 - 60 + cos(a) * 20;
    //  float sy = y1 + 60 + sin(a) * 20;
    //  star1.vertex(sx, sy);
    //  sx = x1 - 60 + cos(a+halfAngle) * 10;
    //  sy = y1 + 60 + sin(a+halfAngle) * 10;
    //  star1.vertex(sx, sy);
    //}
    //star1.endShape(CLOSE);

    //Create star2
    fill(#ffdb58);
    star2 = createShape();
    star2.beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
      float sx = x1 - 60 + cos(a) * 8;
      float sy = y1 + 60 + sin(a) * 8;
      star2.vertex(sx, sy);
      sx = x1 - 60 + cos(a+halfAngle) * 4;
      sy = y1 + 60 + sin(a+halfAngle) * 4;
      star2.vertex(sx, sy);
    }
    star2.endShape(CLOSE);

    //Create star3
    fill(#ffdb58);
    star3 = createShape();
    star3.beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
      float sx = x1 - 60 + cos(a) * 6;
      float sy = y1 + 20 + sin(a) * 6;
      star3.vertex(sx, sy);
      sx = x1 - 60 + cos(a+halfAngle) * 3;
      sy = y1 + 20 + sin(a+halfAngle) * 3;
      star3.vertex(sx, sy);
    }
    star3.endShape(CLOSE);
  }
  
  //Displays, translates, and rotates objects
  void displayTransRotate() {
    if (x_trans + x1-220 > width) {
      x_trans = 0;
      y_trans = random(0, height);
    } else {
      pushMatrix();
      translate(-250, 200);
      translate(x_trans, y_trans);
      bird.resize(70, 50);
      image(bird,x1,y1);
      //moveStar1();
      moveStar2();
      moveStar3();
      x_trans += speed.x;
      popMatrix();
    }
  }

  //void moveStar1() {
  //  pushMatrix();
  //  rotate(theta1);
  //  shape(star1);
  //  theta1 -= 0.1;
  //  popMatrix();
  //}

  void moveStar2() {
    pushMatrix();
    rotate(theta2);
    shape(star2);
    theta2 -= 0.08;
    popMatrix();
  }

  void moveStar3() {
    pushMatrix();
    rotate(theta3);
    shape(star3);
    theta3 -= 0.02;
    popMatrix();
  }
}
