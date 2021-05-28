import java.io.BufferedWriter;
import java.io.FileWriter;
import java.util.List;
import java.util.TreeMap;
import ddf.minim.*;
Minim minim;

//Sounds
AudioPlayer background_sound;
AudioSample click_sound;
AudioSample coin_sound;
AudioSample footsteps_sound;
AudioSample jump_sound;
AudioSample lose_sound;
AudioSample win_sound;
AudioSample both_win_sound;

//Game start image
PImage background;
Button start;
Button quit;

//Global variables for objects in game
Map game_map;
Platform platform1;
Bird bird1;
Bird bird2;
Player blue_player, red_player;
Timer blue_player_timer, red_player_timer, coin_timer, countdown_timer;
int level = 1;
int score = 0;
boolean mute_game;

void setup() {
  size(800, 690);

  //Loading sounds from file
  minim = new Minim(this);
  click_sound = minim.loadSample("sound/click.wav");
  background_sound = minim.loadFile("sound/background.wav");
  coin_sound = minim.loadSample("sound/coin.wav", 512);
  footsteps_sound = minim.loadSample("sound/footsteps.wav", 512);
  jump_sound = minim.loadSample("sound/jump.wav", 512);
  lose_sound = minim.loadSample("sound/lose.wav", 512);
  win_sound = minim.loadSample("sound/win1.wav", 512);
  both_win_sound = minim.loadSample("sound/win2.wav", 512);
  background_sound.play();

  //Loading background
  background = loadImage("screen/start.png");
  start = new Button(width/2-90, height/2+70, 100, 30, 0, "Start");
  quit = new Button(width/2+90, height/2+70, 100, 30, 100, "Quit");
  bird1 = new Bird(0, 0, new PVector(5, 2));
  bird2 = new Bird(0, 0, new PVector(3, 2));

  //Creating the players
  blue_player = new Player("blue/right/blue", "blue/left/blue", 40, 457, "blue");
  red_player = new Player("red/right/red", "red/left/red", 40, 575, "red");
  Player[] players = {blue_player, red_player};

  //Creating the timers
  blue_player_timer = new Timer(90);
  red_player_timer = new Timer(90);
  coin_timer = new Timer(120);
  countdown_timer = new Timer(1000);
  Timer[] timers = {blue_player_timer, red_player_timer, coin_timer, countdown_timer};

  //Creating the game map 
  game_map = new Map(timers, 100, players, level);
}

void draw() {
  background(#171611);

  if (game_map.start) {
    //Rewinds background music if music ended
    if (!mute_game) {
      if (background_sound.position() == background_sound.length() )
      {
        background_sound.rewind();
        background_sound.play();
      }
    }
    
    //Displaying the game map
    if (!game_map.paused_game && !game_map.lost_game && !game_map.won_game) {
      bird1.displayTransRotate();
      bird2.displayTransRotate();
    }
    game_map.display(coin_timer.change_frame(), countdown_timer.change_frame());
    
    //Displaying the blue player
    blue_player.display(blue_player_timer.change_frame());
    blue_player.update();
    blue_player.move(game_map);

    //Displaying the red player
    red_player.display(red_player_timer.change_frame());
    red_player.update();
    red_player.move(game_map);

    if (game_map.level > level) {
      level = game_map.level;
      if (level > 7) {
        game_map.win();
        return;
      }
      //Creating the players
      blue_player = new Player("blue/right/blue", "blue/left/blue", 40, 457, "blue");
      red_player = new Player("red/right/red", "red/left/red", 40, 575, "red");
      Player[] players = {blue_player, red_player};

      //Creating the timers
      blue_player_timer = new Timer(90);
      red_player_timer = new Timer(90);
      coin_timer = new Timer(120);
      countdown_timer = new Timer(1000);
      Timer[] timers = {blue_player_timer, red_player_timer, coin_timer, countdown_timer};
      game_map = new Map(timers, 100, players, level);
      game_map.start = true;
    } else if (game_map.level < level) {
      level = game_map.level;
      //Creating the players
      blue_player = new Player("blue/right/blue", "blue/left/blue", 40, 457, "blue");
      red_player = new Player("red/right/red", "red/left/red", 40, 575, "red");
      Player[] players = {blue_player, red_player};

      //Creating the timers
      blue_player_timer = new Timer(90);
      red_player_timer = new Timer(90);
      coin_timer = new Timer(120);
      countdown_timer = new Timer(1000);
      Timer[] timers = {blue_player_timer, red_player_timer, coin_timer, countdown_timer};
      game_map = new Map(timers, 100, players, level);
      game_map.start = true;
    }
    //noLoop();
  } else {
    image(background, 0, 0);
    textAlign(CENTER);
    textSize(40);
    text("Forest Abyss", width/2, height/2);
    textSize(25);
    text("Among Us Edition", width/2, height/2+30);
    start.display();
    quit.display();
  }
}

void keyPressed() {
  //Setting movement state to true if the game is not paused/lost/won
  if (!game_map.paused_game && !game_map.lost_game && !game_map.won_game && game_map.start) {
    if (keyCode == RIGHT) {
      blue_player.moving_right = true;
    }
    if (keyCode == LEFT) {
      blue_player.moving_left = true;
    }
    if (keyCode == UP) {
      blue_player.moving_up = true;
    }
    if (key == 'd') {
      red_player.moving_right = true;
    }
    if (key == 'a') {
      red_player.moving_left = true;
    }
    if (key == 'w') {
      red_player.moving_up = true;
    }
  }
}

void keyReleased() {
  //Setting movement state to false if key is released
  if (keyCode == RIGHT) {
    blue_player.moving_right = false;
  }
  if (keyCode == LEFT) {
    blue_player.moving_left = false;
  }
  if (keyCode == UP) {
    blue_player.moving_up = false;
  }
  if (key == 'd') {
    red_player.moving_right = false;
  }
  if (key == 'a') {
    red_player.moving_left = false;
  }
  if (key == 'w') {
    red_player.moving_up = false;
  }
  if (game_map.lost_game || game_map.won_game) {
    if (keyCode != RIGHT && keyCode != UP && keyCode != LEFT && keyCode != DOWN ) { 
      game_map.name = game_map.name + key;
    }
  }
}

void mousePressed() {
  //Checks if any of the buttons in the game were pressed
  game_map.checkButton();

  if (game_map.start == false) {
    if (start.checkHover()) {
      click_sound.trigger();
      game_map.start = true;
    } else if (quit.checkHover()) {
      background_sound.pause();
      exit();
    }
  }
}
