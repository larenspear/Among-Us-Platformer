class Timer {
  //Fields --------------------------------------------------------------------------------//
  int timeElapsed, interval;
  boolean paused_timer;
  int begin, duration, time;
  
  //Constructor ---------------------------------------------------------------------------//
  Timer(int _interval) {
    interval = _interval;
    timeElapsed = millis();
  }
  
  //Method: Determines whether it's time to change frames ---------------------------------//
  boolean change_frame() {
    if (!paused_timer) {
      if (millis() - timeElapsed >= interval) {
        timeElapsed = millis();
        return true;
      }
    }
    return false;
  }
  
  //Method: Pauses the timer --------------------------------------------------------------//
  void pause() {
    paused_timer = true;
  }
  
  //Method: Resumes the timer -------------------------------------------------------------//
  void resume() {
    paused_timer = false;
    timeElapsed = millis();
  }
}
