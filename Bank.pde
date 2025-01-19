import java.util.Vector;
import java.util.Random;

Random rand = new Random();

boolean displayFPS = true;

// CUSTOM MOUSE CLICKING TOOL
boolean mouseChoose = false;
void mouseReleased() {
  mouseChoose = true;
  // set to false at the end of drawing phase
}

// CUSTOM KEY CONTROL TOOL
boolean keyReady = true;
void keyReleased() {
  keyReady = true;
  // set to false when a key is pressed
}

// Phase enumerates all the possible phases of play.
enum Phase {playerEntry, play, betweenRounds, gameDone};
// Command enumerates all the possible commands a button can have.
enum Command {start, removePlayer, diceValue, toggleDice, rollDice, newDice, doubles, seven, undo, playerBank, restart};

// Holds all the game logic
GameControl gc = new GameControl();

void setup()
{
  size(1000, 700);
}

void draw()
{
  background(255);
  
  gc.interact();
  gc.drawGUI();
  
  // FPS is displayed on top of everything else.
  if (displayFPS) {
    textSize(30);
    textAlign(RIGHT);
    fill(0, 255, 0);
    text((int)frameRate, 990, 30);
  }
  
  mouseChoose = false;
}
