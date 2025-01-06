class Die {
  private int value;
  private Position pos;
  private Color c;
  
  public Die() {
    value = 1;
    pos = new Position();
    c = new Color();
  }
  
  public Die(Position pos, Color c) {
    value = 1;
    this.pos = pos;
    this.c = c;
  }
  
  public int getValue() { return value; }
  public Position getPos() { return pos; }
  
  public void roll() { value = rand.nextInt(1, 7); }
  
  public void drawDie() {
    int x = pos.getX();
    int y = pos.getY();
    
    //c.setStroke();
    //c.setFillA(10);
    //rect(x, y, 100, 100, 20);
    
    noStroke();
    c.setFill();
    rect(x, y, 100, 100, 30);
    int additiveColor = c.getR() + c.getG() + c.getB();
    fill(255);
    if ((float)additiveColor / 3.0 >= 128.0) {
      fill(0);
    }
    switch (value) {
      case 1:
        drawCenterDot(x, y);
        break;
      case 2:
        drawDiagDots(x, y, false);
        break;
      case 3:
        drawCenterDot(x, y);
        drawDiagDots(x, y, true);
        break;
      case 4:
        drawDiagDots(x, y, false);
        drawDiagDots(x, y, true);
        break;
      case 5:
        drawCenterDot(x, y);
        drawDiagDots(x, y, false);
        drawDiagDots(x, y, true);
        break;
      case 6:
        drawDiagDots(x, y, false);
        drawDiagDots(x, y, true);
        drawHoriDots(x, y);
        break;
      default:
        break;
    }
  }
  
  private void drawCenterDot(int x, int y) {
    circle(x + 50, y + 50, 20);
  }
  private void drawDiagDots(int x, int y, boolean rotated) {
    circle(x + (rotated ? 75 : 25), y + 25, 20);
    circle(x + (rotated ? 25 : 75), y + 75, 20);
  }
  private void drawHoriDots(int x, int y) {
    circle(x + 25, y + 50, 20);
    circle(x + 75, y + 50, 20);
  }
}
