class Player {
  //Fields ---------------------------------------------------------------------------------------------//
  //Player characteristics
  PImage[] player_r, player_l;
  String player_color;
  int current_frame;
  int NUM_PLAYER_FRAMES = 5;
  float PLAYER_WIDTH, PLAYER_HEIGHT;

  //Player movement
  float[] init_player_position;
  float[] player_position;
  float[] player_velocity = new float[]{0, 0};
  float[] player_acceleration = new float[]{0, 0};

  //Player state
  boolean moving_right, moving_left, moving_up, moving_down = false;
  boolean run = false;
  boolean flip = false;
  boolean collision_bottom = false;
  float air_time, moving_right_count, moving_left_count;

  //Constructor ----------------------------------------------------------------------------------------//
  Player(String filepath_r, String filepath_l, float posx, float posy, String _player_color) {
    //Setting player characteristics and movement
    init_player_position = new float[]{posx, posy};
    player_position = new float[]{posx, posy};
    player_color = _player_color;

    //Creating container for array of images & loading images into the container
    player_r = new PImage[NUM_PLAYER_FRAMES];
    player_l = new PImage[NUM_PLAYER_FRAMES];
    for (int i = 0; i < player_r.length; i++) {
      String imageName = filepath_r + (i+1) + ".png";
      player_r[i] = loadImage(imageName);
    }
    for (int i = 0; i < player_l.length; i++) {
      String imageName = filepath_l + (i+1) + ".png";
      player_l[i] = loadImage(imageName);
    }

    //Setting player width and height
    PLAYER_WIDTH = player_r[0].width;
    PLAYER_HEIGHT = player_r[0].height;
  }

  //Method: Displays the player ------------------------------------------------------------------------//
  void display(boolean change_frame) {
    //Determines if it's time to change player frame (for animating purposes)
    if (change_frame) {
      current_frame = (current_frame + 1) % NUM_PLAYER_FRAMES;
    }

    //Displays player based on player state
    if (run) {
      if (!flip) {
        imageMode(CORNER);
        image(player_r[current_frame], player_position[0], player_position[1]);
      } else {
        imageMode(CORNER);
        image(player_l[current_frame], player_position[0], player_position[1]);
      }
    } else {
      if (!flip) {
        imageMode(CORNER);
        image(player_r[0], player_position[0], player_position[1]);
      } else {
        imageMode(CORNER);
        image(player_l[0], player_position[0], player_position[1]);
      }
    }
  }

  //Method: Updates the player movement and state ------------------------------------------------------//
  void update() {
    //Resets velocity to 0
    player_velocity = new float[]{0, 0};

    //Gravity
    player_velocity[1] = player_acceleration[1];
    player_acceleration[1] += 0.2;

    //Puts a cap on the force of gravity
    if (player_acceleration[1] > 5) {
      player_acceleration[1] = 5;
    }

    //Sets player movement variables based on the keys pressed
    if (moving_right) {
      moving_right_count++;
      if (moving_right_count % 20 == 0) {
        if (!mute_game) {
          footsteps_sound.trigger();
        }
      }
      player_velocity[0] += 4;
      run = true;
      flip = false;
    }
    if (moving_left) {
      moving_left_count++;
      if (moving_left_count % 20 == 0) {
        if (!mute_game) {
          footsteps_sound.trigger();
        }
      }
      player_velocity[0] -= 4;
      run = true;
      flip = true;
    }
    if (moving_up) {
      //Restricts jump sound from playing more than once
      if (air_time < 1) {
        if (!mute_game) {
          jump_sound.trigger();
        }
      }

      //Restricts the player from jumping again mid-air
      if (air_time < 6) {
        player_acceleration[1] = -5;
      }
    } 
    if (!(moving_right || moving_left)) {
      run = false;
    }

    //Resets gravity to 0 if there is a bottom collision
    if (collision_bottom) {
      collision_bottom = false;
      player_acceleration[1] = 0;
      air_time = 0;
    } else {
      air_time++;
    }
  }

  //Method: Moves the player based on new updates ------------------------------------------------------//
  void move(Map game_map) {
    //Iterates through the list of coin collisions, set collected state to true, and increase game score
    ArrayList<Coin> coin_collisions = test_coin_collision(game_map.coin_list);
    for (Coin coin : coin_collisions) {
      coin.collected = true;
      //game_map.score += 1;
      score += 1;
      if (!mute_game) {
        coin_sound.trigger();
      }
    }

    //Deals with collisions in the X-axis
    player_position[0] += player_velocity[0];
    ArrayList<PShape> ground_collisionsX = test_collision(game_map.ground_rects);
    for (PShape ground_rect : ground_collisionsX) {
      if (player_velocity[0] > 0) {
        player_position[0] = ground_rect.getVertexX(0) - PLAYER_WIDTH;
      }
      if (player_velocity[0] < 0) {
        player_position[0] = ground_rect.getVertexX(1);
      }
    }
    ArrayList<PShape> red_puddle_collisionsX = test_red_puddle_collision(game_map.red_puddle_rects);
    for (PShape red_puddle_rect : red_puddle_collisionsX) {
      if (player_velocity[0] > 0) {
        player_position[0] = red_puddle_rect.getVertexX(0) - PLAYER_WIDTH;
      }
      if (player_velocity[0] < 0) {
        player_position[0] = red_puddle_rect.getVertexX(1);
      }
    }
    ArrayList<PShape> blue_puddle_collisionsX = test_blue_puddle_collision(game_map.blue_puddle_rects);
    for (PShape blue_puddle_rect : blue_puddle_collisionsX) {
      if (player_velocity[0] > 0) {
        player_position[0] = blue_puddle_rect.getVertexX(0) - PLAYER_WIDTH;
      }
      if (player_velocity[0] < 0) {
        player_position[0] = blue_puddle_rect.getVertexX(1);
      }
    }
    
    //Deals with the collisions in the Y-axis
    player_position[1] += player_velocity[1];
    ArrayList<PShape> ground_collisionsY = test_collision(game_map.ground_rects);
    for (PShape ground_rect : ground_collisionsY) {
      if (player_velocity[1] > 0) {
        player_position[1] = ground_rect.getVertexY(0) - PLAYER_HEIGHT;
        collision_bottom = true;
      }
      if (player_velocity[1] < 0) {
        player_position[1] = ground_rect.getVertexY(2);
      }
    }
    ArrayList<PShape> red_puddle_collisionsY = test_collision(game_map.red_puddle_rects);
    for (PShape red_puddle_rect : red_puddle_collisionsY) {
      if (player_velocity[1] > 0) {
        player_position[1] = red_puddle_rect.getVertexY(0) - PLAYER_HEIGHT;
        collision_bottom = true;
        //Loses game if blue player collides with red puddle
        if (player_color == "blue") {
          game_map.lose();
        }
      }
      if (player_velocity[1] < 0) {
        player_position[1] = red_puddle_rect.getVertexY(2);
      }
    }
    ArrayList<PShape> blue_puddle_collisionsY = test_collision(game_map.blue_puddle_rects);
    for (PShape blue_puddle_rect : blue_puddle_collisionsY) {
      if (player_velocity[1] > 0) {
        player_position[1] = blue_puddle_rect.getVertexY(0) - PLAYER_HEIGHT;
        collision_bottom = true;
        //Loses game if red player collides with blue puddle
        if (player_color == "red") {
          game_map.lose();
        }
      }
      if (player_velocity[1] < 0) {
        player_position[1] = blue_puddle_rect.getVertexY(2);
      }
    }
    ArrayList<PShape> door_collisionsY = test_door_collision(game_map.door_rects);
    for (PShape door_rect : door_collisionsY) {
      if (player_color == "blue") {
        game_map.blue_won = true;
      } else if (player_color == "red") {
        game_map.red_won = true;
      }
      game_map.win();
    }
    ArrayList<Platform> platform_collisionsY = test_platform_collision(game_map.platform_list);
    for (Platform platform : platform_collisionsY) {
      if (player_velocity[1] > 0) {
        player_position[1] = platform.platform_position[1] - PLAYER_HEIGHT;
        collision_bottom = true;
      }
      if (player_velocity[1] < 0) {
        player_position[1] = platform.platform_position[1] + platform.PLATFORM_HEIGHT;
      }
    }
    
    //ArrayList<Platform> platform_collisionsX = test_platform_collision(game_map.platform_list);
    //for (Platform platform : platform_collisionsX) {
    //  if (player_velocity[0] > 0) {
    //    player_position[0] = platform.platform_position[0] - PLAYER_WIDTH;
    //  }
    //  if (player_velocity[0] < 0) {
    //    player_position[0] = platform.platform_position[0] + platform.PLATFORM_WIDTH;
    //  }
    //}

  }

  //Method: Tests for and returns a list of ground collisions ------------------------------------------//
  ArrayList<PShape> test_collision(ArrayList<PShape> ground_rects) {
    ArrayList<PShape> ground_collisions = new ArrayList<PShape>();
    for (PShape ground_rect : ground_rects) {
      if (!((player_position[0] + PLAYER_WIDTH <= ground_rect.getVertexX(0)) || 
        (player_position[0] >= ground_rect.getVertexX(1)) ||
        (player_position[1] + PLAYER_HEIGHT <= ground_rect.getVertexY(0)) ||
        (player_position[1] >= ground_rect.getVertexY(2)))) {
        ground_collisions.add(ground_rect);
      }
    }
    return ground_collisions;
  }

  //Method: Tests for and returns a list of red puddle collisions --------------------------------------//
  ArrayList<PShape> test_red_puddle_collision(ArrayList<PShape> red_puddle_rects) {
    ArrayList<PShape> red_puddle_collisions = new ArrayList<PShape>();
    for (PShape red_puddle_rect : red_puddle_rects) {
      if (!((player_position[0] + PLAYER_WIDTH <= red_puddle_rect.getVertexX(0)) || 
        (player_position[0] >= red_puddle_rect.getVertexX(1)) ||
        (player_position[1] + PLAYER_HEIGHT <= red_puddle_rect.getVertexY(0)) ||
        (player_position[1] >= red_puddle_rect.getVertexY(2)))) {
        red_puddle_collisions.add(red_puddle_rect);
      }
    }
    return red_puddle_collisions;
  }

  //Method: Tests for and returns a list of blue puddle collisions -------------------------------------//
  ArrayList<PShape> test_blue_puddle_collision(ArrayList<PShape> blue_puddle_rects) {
    ArrayList<PShape> blue_puddle_collisions = new ArrayList<PShape>();
    for (PShape blue_puddle_rect : blue_puddle_rects) {
      if (!((player_position[0] + PLAYER_WIDTH <= blue_puddle_rect.getVertexX(0)) || 
        (player_position[0] >= blue_puddle_rect.getVertexX(1)) ||
        (player_position[1] + PLAYER_HEIGHT <= blue_puddle_rect.getVertexY(0)) ||
        (player_position[1] >= blue_puddle_rect.getVertexY(2)))) {
        blue_puddle_collisions.add(blue_puddle_rect);
      }
    }
    return blue_puddle_collisions;
  }

  //Method: Tests for and returns a list of door collisions --------------------------------------------//
  ArrayList<PShape> test_door_collision(ArrayList<PShape> door_rects) {
    ArrayList<PShape> door_collisions = new ArrayList<PShape>();
    for (PShape door_rect : door_rects) {
      if (!((player_position[0] + PLAYER_WIDTH <= door_rect.getVertexX(0)) || 
        (player_position[0] >= door_rect.getVertexX(1)) ||
        (player_position[1] + PLAYER_HEIGHT <= door_rect.getVertexY(0)) ||
        (player_position[1] >= door_rect.getVertexY(2)))) {
        door_collisions.add(door_rect);
      }
    }
    return door_collisions;
  }

  //Method: Tests for and returns a list of coin collisions --------------------------------------------//
  ArrayList<Coin> test_coin_collision(ArrayList<Coin> coin_list) {
    ArrayList<Coin> coin_collisions = new ArrayList<Coin>();
    for (Coin coin : coin_list) {
      if (!((player_position[0] + PLAYER_WIDTH <= coin.coin_rect.getVertexX(0)) || 
        (player_position[0] >= coin.coin_rect.getVertexX(1)) ||
        (player_position[1] + PLAYER_HEIGHT <= coin.coin_rect.getVertexY(0)) ||
        (player_position[1] >= coin.coin_rect.getVertexY(2)))) {
        coin_collisions.add(coin);
      }
    }
    return coin_collisions;
  }

  //Method: Tests for and returns a list of platform collisions ----------------------------------------//
  ArrayList<Platform> test_platform_collision(ArrayList<Platform> platform_list) {
    ArrayList<Platform> platform_collisions = new ArrayList<Platform>();
    for (Platform platform : platform_list) {
      if (!((player_position[0] + PLAYER_WIDTH <= platform.platform_position[0]) || 
        (player_position[0] >= platform.platform_position[0] + platform.PLATFORM_WIDTH) ||
        (player_position[1] + PLAYER_HEIGHT <= platform.platform_position[1]) ||
        (player_position[1] >= platform.platform_position[1] + platform.PLATFORM_HEIGHT))) {
        platform_collisions.add(platform);
      }
    }
    return platform_collisions;
  }
}
