Credit to my partners on this project, Daniel Kim, Anna Lai, and Sanya Srivastava!

Demo of the game: https://youtu.be/KTYnQDdqpsI

To run this game, you have to download Processing. Unfortunately there's no real easy way to run this on the web without manually porting it to Javascript.

Download the project directory and open the "bumblefumble_finalproject.pde" file and you should be able to play the game.

Game Controls ---------------------------- 
- Buttons
  Start: Appears when you run the kernel. Click to start the game.
  Pause: Appears on the upper right corner. Click to pause the game.
  Mute: Appears on the upper right corner. Click to mute the sound.
  Continue: Appears when you pause the game. Click to continue the game.
  Try Again: Appears when you lose the game. Click to try again from level 1.
  Submit: Appears when you lose/win the game. Press submit after you enter your name to see the leaderboard.
  Quit: Appears when you pause, win, or lose the game. Click to exit the game.

- Player Red:
  UP key: Jump
  RIGHT key: Move right
  LEFT key: Move Left

- Player Blue:
  w: Jump
  d: Move Right
  a: Move Left

Game Instructions ---------------------------- 
1. Run the kernel
2. You may navigate the characters using the game controls stated above
3. Avoid obstacles
   - The red player can ONLY run over the red lava
   - The blue player can ONLY run over the blue lava
   - Step on the pushers for the platform to move down so that the players can step on it
4. Collect the coins to get a higher score
5. You may pause/mute the game at anytime by pressing the buttons on the upper right corner
6. If both players make it to the door within the time frame, you advance to the next level. If you die (fall into the wrong puddles) or fail to make it within the time, you lose (lose screen will appear and you will be prompted to "Try Again" or "Quit"). If you finish all the levels, you win (win screen will appear).

Notes ---------------------------- 
- There's a slight glitch with the platforms. Make sure to not run into the platforms from the side or else you'll move somewhere random on the screen. Just jump on the platform.
- If you want to start at a different level right away to test functionality, you can change the global variable "level" to the level number of your choice.
