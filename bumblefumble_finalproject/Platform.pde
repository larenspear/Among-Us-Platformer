class Platform {
  //Fields ---------------------------------------------------------------------------------------------//
  //Platform characteristics
  PImage platform_img;
  float PLATFORM_WIDTH, PLATFORM_HEIGHT;
  PShape platform_rect;
  PShape stopper_rect;
  
  //Component classes
  ArrayList<Pusher> pusher_list = new ArrayList<Pusher>();
  
  //Platform movement
  float[] init_platform_position;
  float[] platform_position;
  float[] platform_velocity = new float[]{0, 0};

  //Platform state
  boolean moving_up, moving_down = false;
  boolean pusher_pressed;

  //Constructor ----------------------------------------------------------------------------------------//
  Platform(PImage _platform_img, PShape _platform_rect, float posx, float posy) {
    //Setting player characteristics
    platform_img = _platform_img;
    platform_rect = _platform_rect;
    
    //Setting position
    init_platform_position = new float[]{posx, posy};
    platform_position = new float[]{posx, posy};
    
    //Creating stopper
    stopper_rect = createShape();
    stopper_rect.beginShape();
    stopper_rect.vertex(init_platform_position[0], init_platform_position[1]-10);
    stopper_rect.vertex(init_platform_position[0]+10, init_platform_position[1]-10);
    stopper_rect.vertex(init_platform_position[0]+10, init_platform_position[1]);
    stopper_rect.vertex(init_platform_position[0], init_platform_position[1]);
    stopper_rect.endShape(CLOSE);
    
    //Setting player width and height
    PLATFORM_WIDTH = platform_img.width;
    PLATFORM_HEIGHT = platform_img.height;
  }

  //Method: Displays the platform ----------------------------------------------------------------------//
  void display() {
    //Displays player based on player state
    imageMode(CORNER);
    image(platform_img, platform_position[0], platform_position[1]);
  }

  //Method: Updates the platform movement and state ----------------------------------------------------//
  void update() {
    //Resets velocity to 0
    platform_velocity = new float[]{0, 0};

    //Sets platform movement variables based on the keys pressed
    if (moving_up) {
      platform_velocity[1] -= 2;
    }
    if (moving_down) {
      platform_velocity[1] += 2;
    }
  }

  //Method: Moves the platform based on new updates ----------------------------------------------------//
  void move(ArrayList<PShape> ground_rects, Player[] players) {
    //Deals with the collisions in the Y-axis
    platform_position[1] += platform_velocity[1];
    ArrayList<PShape> ground_collisionsY = test_collision(ground_rects);
    for (PShape ground_rect : ground_collisionsY) {
      if (platform_velocity[1] > 0) {
        platform_position[1] = ground_rect.getVertexY(0) - PLATFORM_HEIGHT;
      }
      if (platform_velocity[1] < 0) {
        platform_position[1] = ground_rect.getVertexY(2);
      }
    }
    PShape stopper_collisionY = test_stopper_collision();
    if (stopper_collisionY == stopper_rect) {
      if (platform_velocity[1] < 0) {
        platform_position[1] = stopper_rect.getVertexY(2);
      }
    }
    ArrayList<Player> player_collisionsY = test_player_collision(players);
    for (Player player : player_collisionsY) {
      if (platform_velocity[1] > 0) {
        platform_position[1] = player.player_position[1] - PLATFORM_HEIGHT;
      }
    }
  }
  
  //Method: Tests for and returns a list of stopper collisions ------------------------------------------//
  PShape test_stopper_collision() {
    PShape stopper_collision = new PShape();
    if (!((platform_position[0] + PLATFORM_WIDTH <= stopper_rect.getVertexX(0)) || 
      (platform_position[0] >= stopper_rect.getVertexX(1)) ||
      (platform_position[1] + PLATFORM_HEIGHT <= stopper_rect.getVertexY(0)) ||
      (platform_position[1] >= stopper_rect.getVertexY(2)))) {
      stopper_collision = stopper_rect;
    }
    return stopper_collision;
  }
  
  //Method: Tests for and returns a list of ground collisions ------------------------------------------//
  ArrayList<PShape> test_collision(ArrayList<PShape> ground_rects) {
    ArrayList<PShape> ground_collisions = new ArrayList<PShape>();
    for (PShape ground_rect : ground_rects) {
      if (!((platform_position[0] + PLATFORM_WIDTH <= ground_rect.getVertexX(0)) || 
        (platform_position[0] >= ground_rect.getVertexX(1)) ||
        (platform_position[1] + PLATFORM_HEIGHT <= ground_rect.getVertexY(0)) ||
        (platform_position[1] >= ground_rect.getVertexY(2)))) {
        ground_collisions.add(ground_rect);
      }
    }
    return ground_collisions;
  }
  
  //Method: Tests for and returns a list of player collisions ------------------------------------------//
  ArrayList<Player> test_player_collision(Player[] player_list) {
    ArrayList<Player> player_collisions = new ArrayList<Player>();
    for (Player player : player_list) {
      if (!((platform_position[0] + PLATFORM_WIDTH <= player.player_position[0]) || 
        (platform_position[0] >= player.player_position[0] + player.PLAYER_WIDTH) ||
        (platform_position[1] + PLATFORM_HEIGHT <= player.player_position[1]) ||
        (platform_position[1] >= player.player_position[1] + player.PLAYER_HEIGHT))) {
        player_collisions.add(player);
      }
    }
    return player_collisions;
  }
}
