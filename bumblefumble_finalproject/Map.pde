class Map {
  //Fields ---------------------------------------------------------------------------------------------//
  //Map characteristics
  int[][] game_map;
  PImage[] ground_images;
  float TILE_WIDTH, TILE_HEIGHT;
  int NUM_GROUND_IMAGES = 10;
  int NUM_COIN_FRAMES = 5;
  String name = "";
  PrintWriter scoring;

  //Rects (for collision testing)
  ArrayList<PShape> ground_rects = new ArrayList<PShape>();
  ArrayList<PShape> red_puddle_rects = new ArrayList<PShape>();
  ArrayList<PShape> blue_puddle_rects = new ArrayList<PShape>();
  ArrayList<PShape> door_rects = new ArrayList<PShape>();

  //Component classes
  Timer[] timers;
  Player[] players;
  ArrayList<Coin> coin_list = new ArrayList<Coin>();
  ArrayList<Platform> platform_list = new ArrayList<Platform>();
  ArrayList<Pusher> pusher_list = new ArrayList<Pusher>();
  Button b1 = new Button(width/2-90, height/2, 100, 30, 0, "Continue");
  Button b2 = new Button(width/2-90, height/2, 100, 30, 0, "Try Again");
  Button b3 = new Button(width/2+90, height/2, 100, 30, 100, "Quit");
  Button b4 = new Button(775, 20, 30, 30, 100, "||");
  Button b5 = new Button(730, 20, 50, 30, 100, "Mute");
  Button b6 = new Button(width/2+10, height/2 + 100, 100, 30, 0, "Submit");

  //Map state
  //int score;
  int current_coin_frame;
  int init_time_left, time_left;
  boolean paused_game, lost_game, won_game, leaderboard;
  boolean blue_won, red_won;
  boolean pusher_pressed;
  int lose_count, lose_count_2, win_count, both_win_count;
  boolean start;
  int level;

  //Constructor ----------------------------------------------------------------------------------------//
  Map(Timer[] _timers, int duration, Player[] _players, int _level) {
    //Setting map state and component classes
    timers = _timers;
    time_left = init_time_left = duration;
    players = _players;
    level = _level;

    //Creating container for array of images & loading images into the container
    ground_images = new PImage[NUM_GROUND_IMAGES];
    for (int i = 0; i < ground_images.length; i++) {
      String imageName = "tiles/ground/ground" + (i) + ".png";
      ground_images[i] = loadImage(imageName);
      if (i != 3) {
        ground_images[i].resize(38, 38);
      }
    }

    //Setting tile width and height values
    TILE_WIDTH = ground_images[0].width;
    TILE_HEIGHT = ground_images[0].height;

    //Creating nested arrays for game map levels
    String levelString = "levels/level" + str(level) + ".txt";

    String[] lines = loadStrings(levelString);
    String[][] map = new String[18][21];
    for (int i = 0; i < 18; ++i) {
      for (int j = 0; j < 21; ++j) {
        map[i][j] = lines[i].split(" ")[j];
      }
    }

    int[][] intMap = new int[18][21];
    for (int i = 0; i < 18; ++i) {
      for (int j = 0; j < 21; ++j) {
        intMap[i][j] = int(map[i][j]);
      }
    }

    game_map = intMap;

    //Iterating through game map array 
    for (int y = 0; y < game_map.length; y++) {
      for (int x = 0; x < game_map[y].length; x++) {

        //Creating a ground rect
        if (game_map[y][x] >= 1 && game_map[y][x] <= 9) {
          PShape ground_rect = createShape();
          ground_rect.beginShape();
          ground_rect.vertex(x*TILE_WIDTH, y*TILE_HEIGHT);
          ground_rect.vertex(x*TILE_WIDTH+TILE_WIDTH, y*TILE_HEIGHT);
          ground_rect.vertex(x*TILE_WIDTH+TILE_WIDTH, y*TILE_HEIGHT+TILE_HEIGHT);
          ground_rect.vertex(x*TILE_WIDTH, y*TILE_HEIGHT+TILE_HEIGHT);
          ground_rect.endShape(CLOSE);

          //Adding the rect to the appropriate array list
          if (game_map[y][x] == 3) {
            door_rects.add(ground_rect);
          } else if (game_map[y][x] == 4) {
            red_puddle_rects.add(ground_rect);
          } else if (game_map[y][x] == 5) {
            blue_puddle_rects.add(ground_rect);
          } else {
            ground_rects.add(ground_rect);
          }
        }

        //Creating the coin rect and instance of a coin then adding it to the coin list
        if (game_map[y][x] == 10) {
          PShape coin_rect = createShape();
          coin_rect.beginShape();
          coin_rect.vertex(x*TILE_WIDTH, y*TILE_HEIGHT);
          coin_rect.vertex(x*TILE_WIDTH+TILE_WIDTH, y*TILE_HEIGHT);
          coin_rect.vertex(x*TILE_WIDTH+TILE_WIDTH, y*TILE_HEIGHT+TILE_HEIGHT);
          coin_rect.vertex(x*TILE_WIDTH, y*TILE_HEIGHT+TILE_HEIGHT);
          coin_rect.endShape(CLOSE);

          PImage[] coin_frames = new PImage[5];
          for (int i = 0; i < coin_frames.length; i++) {
            String imageName = "tiles/coins/coin" + (i+1) + ".png";
            coin_frames[i] = loadImage(imageName);
          }

          Coin coin = new Coin(coin_frames, coin_rect);
          coin_list.add(coin);
        }

        //Creating the platform rect and instance of a platform then adding it to the platform list
        if (game_map[y][x] == 11 || game_map[y][x] == 13) {
          PShape platform_rect = createShape();
          platform_rect.beginShape();
          platform_rect.vertex(x*TILE_WIDTH, y*TILE_HEIGHT);
          platform_rect.vertex(x*TILE_WIDTH+TILE_WIDTH*2, y*TILE_HEIGHT);
          platform_rect.vertex(x*TILE_WIDTH+TILE_WIDTH*2, y*TILE_HEIGHT+10);
          platform_rect.vertex(x*TILE_WIDTH, y*TILE_HEIGHT+10);
          platform_rect.endShape(CLOSE);

          PImage platform_img = loadImage("tiles/platform/platform1.png");

          Platform platform = new Platform(platform_img, platform_rect, x*TILE_WIDTH, y*TILE_HEIGHT);
          platform_list.add(platform);
        }

        //Creating the pusher rect and instance of a pusher then adding it to the pusher list
        if (game_map[y][x] == 12 || game_map[y][x] == 14) {
          PShape pusher_rect = createShape();
          pusher_rect.beginShape();
          pusher_rect.vertex(x*TILE_WIDTH, y*TILE_HEIGHT);
          pusher_rect.vertex(x*TILE_WIDTH+TILE_WIDTH, y*TILE_HEIGHT);
          pusher_rect.vertex(x*TILE_WIDTH+TILE_WIDTH, y*TILE_HEIGHT+TILE_HEIGHT);
          pusher_rect.vertex(x*TILE_WIDTH, y*TILE_HEIGHT+TILE_HEIGHT);
          pusher_rect.endShape(CLOSE);

          PImage pusher_img = loadImage("tiles/pusher/pusher1.png");

          Pusher pusher = new Pusher(pusher_img, pusher_rect);
          pusher_list.add(pusher);
        }
      }
    }

    //Add pushers to appropriate platforms
    int count = 0;
    for (Platform platform : platform_list) {
      for (int i = 0; i < 2; i++) {
        platform.pusher_list.add(pusher_list.get(count));
        count++;
      }
    }
  }

  //Method: Iterates through game map and displays images/text -----------------------------------------//
  void display(boolean coin_change_frame, boolean counter_change_frame) {
    //Displays grass, dirt, red puddles, blue puddles, and doors
    for (int y = 0; y < game_map.length; y++) {
      for (int x = 0; x < game_map[y].length; x++) {
        if (game_map[y][x] == 1) {
          imageMode(CORNER);
          image(ground_images[1], x*TILE_WIDTH, y*TILE_HEIGHT);
        }
        if (game_map[y][x] == 2) {
          imageMode(CORNER);
          image(ground_images[2], x*TILE_WIDTH, y*TILE_HEIGHT);
        }
        if (game_map[y][x] == 3) {
          imageMode(CORNER);
          image(ground_images[3], x*TILE_WIDTH, y*TILE_HEIGHT);
        }
        if (game_map[y][x] == 4) {
          imageMode(CORNER);
          image(ground_images[4], x*TILE_WIDTH, y*TILE_HEIGHT);
        }
        if (game_map[y][x] == 5) {
          imageMode(CORNER);
          image(ground_images[5], x*TILE_WIDTH, y*TILE_HEIGHT);
        }
        if (game_map[y][x] == 6) {
          imageMode(CORNER);
          image(ground_images[6], x*TILE_WIDTH, y*TILE_HEIGHT);
        }
        if (game_map[y][x] == 7) {
          imageMode(CORNER);
          image(ground_images[7], x*TILE_WIDTH, y*TILE_HEIGHT);
        }
        if (game_map[y][x] == 8) {
          imageMode(CORNER);
          image(ground_images[8], x*TILE_WIDTH, y*TILE_HEIGHT);
        }
        if (game_map[y][x] == 9) {
          imageMode(CORNER);
          image(ground_images[9], x*TILE_WIDTH, y*TILE_HEIGHT);
        }
      }
    }

    //Determines if it's time to change coin frame (for animating purposes)
    if (coin_change_frame) {
      current_coin_frame = (current_coin_frame + 1) % NUM_COIN_FRAMES;
    }

    //Displays coins, determines if coins has been collected, and removes the collected coins
    ArrayList<Coin> coin_remove = new ArrayList<Coin>();
    for (Coin coin : coin_list) {
      coin.display(current_coin_frame);
      if (coin.collected) {
        coin_remove.add(coin);
      }
    }
    coin_list.removeAll(coin_remove);

    //Displays pusher
    for (Pusher pusher : pusher_list) {
      pusher.display();
    }

    //Displays current level and score
    textSize(20);
    textAlign(LEFT);
    text("Level: " + level + "  Score: " + score, 10, 25);

    //Displays countdown timer
    if (counter_change_frame) {
      time_left -= 1;
    }
    if (time_left > 0) {
      int min = time_left / 60;
      int sec = time_left % 60;
      PFont font = createFont("Georgia", 32);
      textSize(32);
      textAlign(CENTER);
      textFont(font);
      text("Time: " + nf(min, 1) + ":" + nf(sec, 2), width/2, 30);
    } else {
      lose();
    }

    //Displays appropriate screens based on status of game
    if (paused_game) {
      PFont font = createFont("Georgia", 32);
      textAlign(CENTER);
      textFont(font);
      text("PAUSE", width/2, height/2-50);
      tint(0, 128);
      b1.display();
      b3.display();
    } else if (lost_game) {
      if (leaderboard) {
        PFont font = createFont("Georgia", 32);
        textAlign(CENTER);
        textFont(font);
        text("LEADERBOARD", width / 2, height / 2 - 250);
        tint(0, 128);
        b2.display();
        b3.display();
        // reading();
        parseFile();
      } else {
        PFont font = createFont("Georgia", 32);
        textAlign(CENTER);
        textFont(font);
        text("YOU LOSE", width/2, height/2-200);
        tint(0, 128);
        text("Enter name: " + name, width / 2, height / 2 + 200);
        b2.display();
        b3.display();
        b6.display();
      }
    } else if (won_game) {
      if (leaderboard) {
        PFont font = createFont("Georgia", 32);
        textAlign(CENTER);
        textFont(font);
        text("LEADERBOARD", width / 2, height / 2 - 250);
        tint(0, 128);
        b2.display();
        b3.display();
        parseFile();
      } else {
        PFont font = createFont("Georgia", 32);
        textAlign(CENTER);
        textFont(font);
        text("YOU WIN!", width/2, height/2-50);
        text("Enter name: " + name, width / 2, height / 2 + 200);
        tint(0, 128);
        b2.display();
        b3.display();
        b6.display();
      }
    } else {
      textSize(12);
      textAlign(LEFT);
      for (Player player : players) {
        if (player.player_position[0] == player.init_player_position[0] && player.player_position[1] >= player.init_player_position[1]-30 && player.player_color == "blue") {
          text("Use arrow keys for blue player", 120, 500);
        } else if (player.player_position[0] == player.init_player_position[0] && player.player_position[1] >= player.init_player_position[1]-30 && player.player_color == "red") {
          text("Use a, w, d for red player", 120, 615);
        }
      }
      b4.display();
      b5.display();
      noTint();
    }

    //Grabs list of collisions with pusher
    ArrayList<Pusher> pusher_collisions = test_pusher_collision(players);
    for (Platform platform : platform_list) {      
      //Iterates through list of pusher collisions and sets pusher_pressed field to true if pusher is associated with platform
      for (Pusher pusher : pusher_collisions) {
        if (platform.pusher_list.contains(pusher)) {
          platform.pusher_pressed = true;
        }
      }

      //Sets pusher_pressed field to false if there are no collisions
      if (pusher_collisions.isEmpty()) {
        platform.pusher_pressed = false;
      }

      //Updates platform's movement state
      if (platform.pusher_pressed) {
        platform.moving_down = true;
        platform.moving_up = false;
      } else {
        platform.moving_down = false;
        platform.moving_up = true;
      }

      //Display, update, and move platform
      platform.display();
      platform.update();
      platform.move(ground_rects, players);
    }
  }

  //Method: Checks for which button was pressed and performs an action ---------------------------------//
  void checkButton() {
    if (paused_game) {
      if (b1.checkHover()) {
        click_sound.trigger();
        resume();
      } else if (b3.checkHover()) {
        click_sound.trigger();
        background_sound.pause();
        exit();
      }
    } else if (lost_game) {
      if (b2.checkHover()) {
        click_sound.trigger();
        restart();
      } else if (b3.checkHover()) {
        click_sound.trigger();
        background_sound.pause();
        exit();
      } else if (b6.checkHover()) {
        click_sound.trigger();
        leader();
      }
    } else if (won_game) {
      if (b2.checkHover()) {
        restart();
      } else if (b3.checkHover()) {
        click_sound.trigger();
        background_sound.pause();
        exit();
      } else if (b6.checkHover()) {
        click_sound.trigger();
        leader();
      }
    } else {
      if (b4.checkHover()) {
        click_sound.trigger();
        pause();
      } else if (b5.checkHover()) {
        if (mute_game) {
          unmute();
        } else {
          click_sound.trigger();
          mute();
        }
      }
    }
  }

  //Method: Tests for and returns a list of pusher collisions with the player --------------------------//
  ArrayList<Pusher> test_pusher_collision(Player[] players) {
    ArrayList<Pusher> pusher_collisions = new ArrayList<Pusher>();
    for (Player player : players) {
      for (Pusher pusher : pusher_list) {
        if (!((pusher.pusher_rect.getVertexX(1) <= player.player_position[0]) || 
          (pusher.pusher_rect.getVertexX(0) >= player.player_position[0] + player.PLAYER_WIDTH) ||
          (pusher.pusher_rect.getVertexY(2) <= player.player_position[1]) ||
          (pusher.pusher_rect.getVertexY(0) >= player.player_position[1] + player.PLAYER_HEIGHT))) {
          pusher_collisions.add(pusher);
        }
      }
    }
    return pusher_collisions;
  }

  //Method: Sets press_pusher to true ------------------------------------------------------------------//
  void press_pusher() {
    pusher_pressed = true;
  }

  //Method: Sets release_pusher to true ----------------------------------------------------------------//
  void release_pusher() {
    pusher_pressed = false;
  }

  //Method: Sets pause_game to true --------------------------------------------------------------------//
  void pause() {
    paused_game = true;
    for (Timer timer : timers) {
      timer.pause();
    }
  }

  //Method: Sets mute_game to true --------------------------------------------------------------------//
  void mute() {
    mute_game = true;
    background_sound.pause();
    coin_sound.stop();
    footsteps_sound.stop();
    jump_sound.stop();
    lose_sound.stop();
    win_sound.stop();
    both_win_sound.stop();
  }

  //Method: Sets mute_game to true --------------------------------------------------------------------//
  void unmute() {
    background_sound.play();
    mute_game = false;
  }

  //Method: Sets pause_game to false -------------------------------------------------------------------//
  void resume() {
    paused_game = false;
    for (Timer timer : timers) {
      timer.resume();
    }
  }

  //Method: Sets lost_game to true ---------------------------------------------------------------------//
  void lose() {
    lose_count++;
    if (lose_count == 1) {
      if (!mute_game) {
        lose_sound.trigger();
      }
    }
    lost_game = true;
    for (Timer timer : timers) {
      timer.pause();
    }
  }

  //Method: Sets won_game to true ----------------------------------------------------------------------//
  void win() {
    win_count++;
    if (win_count == 1) {
      if (!mute_game) {
        win_sound.trigger();
      }
    }
    if (blue_won && red_won) {
      won_game = true;
      both_win_count++;
      if (both_win_count == 1) {
        level += 1;
        if (!mute_game) {
          both_win_sound.trigger();
        }
      }
      for (Timer timer : timers) {
        timer.pause();
      }
    }
  }

  //Method: Sets leaderboard to true -------------------------------------------------------------------//
  void leader() {
    leaderboard = true;
    lose_count_2++;

    if (lose_count_2 == 1) {
      try {
        File f = new File(dataPath("scoring.txt"));
        scoring = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
        scoring.println(name + "," + score);
        scoring.flush();
      }
      catch (IOException e) {
        e.printStackTrace();
      }
    }
  }

  //Method: Resets game to initial state ---------------------------------------------------------------//
  void restart() {
    //Resets players' position to initial position and direction
    blue_won = red_won = lost_game = won_game = false;
    leaderboard = false;
    score = 0;
    time_left = init_time_left;
    name = "";
    lose_count = lose_count_2 = win_count = both_win_count = 0;
    level = 1;

    //Resumes the timer
    for (Timer timer : timers) {
      timer.resume();
    }

    //Resets players' position to initial position and direction
    for (Player player : players) {
      player.flip = false;
      player.player_position[0] = player.init_player_position[0];
      player.player_position[1] = player.init_player_position[1];
    }

    //Empties the coin_list and repopulates the list with newly created coins
    coin_list = new ArrayList<Coin>();
    for (int y = 0; y < game_map.length; y++) {
      for (int x = 0; x < game_map[y].length; x++) {
        if (game_map[y][x] == 10) {
          PShape coin_rect = createShape();
          coin_rect.beginShape();
          coin_rect.vertex(x*TILE_WIDTH, y*TILE_HEIGHT);
          coin_rect.vertex(x*TILE_WIDTH+TILE_WIDTH, y*TILE_HEIGHT);
          coin_rect.vertex(x*TILE_WIDTH+TILE_WIDTH, y*TILE_HEIGHT+TILE_HEIGHT);
          coin_rect.vertex(x*TILE_WIDTH, y*TILE_HEIGHT+TILE_HEIGHT);
          coin_rect.endShape(CLOSE);

          PImage[] coin_frames = new PImage[5];
          for (int i = 0; i < coin_frames.length; i++) {
            String imageName = "tiles/coins/coin" + (i+1) + ".png";
            coin_frames[i] = loadImage(imageName);
          }

          Coin coin = new Coin(coin_frames, coin_rect);
          coin_list.add(coin);
        }
      }
    }
  }

  void parseFile() {
    TreeMap<Integer, List<String>> dict = new TreeMap<Integer, List<String>>();
    //Set up a file reader
    BufferedReader reader = createReader("scoring.txt");
    String line = null;
    try {
      //Read your file line by line
      while ((line = reader.readLine()) != null) {
        String[] record = split(line, ",");
        Integer score = Integer.valueOf(record[1]);
        List<String> among = null;

        //Check if a player with this score already exists
        //If not, create a new list
        if ((among = dict.get(score)) == null) {
          among = new ArrayList<String>(1);
          among.add(record[0]);
          dict.put(Integer.valueOf(record[1]), among);
          //If yes, add to the existing list
        } else {
          among.add(record[0]);
        }
      }

      reader.close();
    } 
    catch (IOException e) {
      e.printStackTrace();
    }
    //Iterate in descending order
    int count_score = 0;
    for (Integer score : dict.descendingKeySet()) {
      for (String player : dict.get(score)) {
        count_score++;
        if (count_score < 6) {
          text(player + ": " + score, width / 2, height / 2 - 220 + (32 * count_score));
        } else {
          break;
        }
      }
    }
  }
}
