import java.util.Vector;
import java.util.Random;

Random rand = new Random();

Die testDie1 = new Die(new Position(390, 300), new Color(rand.nextInt(0, 256), rand.nextInt(0, 256), rand.nextInt(0, 256)));
Die testDie2 = new Die(new Position(510, 300), new Color(rand.nextInt(0, 256), rand.nextInt(0, 256), rand.nextInt(0, 256)));

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

enum Phase {playerEntry, play, betweenRounds};
enum Command {start, removePlayer, diceValue, doubles, seven, undo, playerBank};

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
  
  // FPS is displayed above everything else
  if (displayFPS) {
    textSize(30);
    textAlign(RIGHT);
    fill(0, 255, 0);
    text((int)frameRate, 990, 30);
  }
  
  if (mouseChoose) {
    testDie1.roll();
    testDie2.roll();
  }
  
  testDie1.drawDie();
  testDie2.drawDie();
  
  mouseChoose = false;
}
