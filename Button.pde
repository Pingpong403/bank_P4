class Button {
  private Position pos;
  private int w;
  private int h;
  private Command c;
  private int value = 0;
  private String text = "";
  private boolean pressed = false;
  private boolean active = true;
  private Color textColor = new Color(0);
  
  public Button() {
    pos = new Position();
    w = 90;
    h = 40;
    c = Command.start;
  }
  
  public Button(Position pos, Command c, String text) {
    this.pos = pos;
    w = 90;
    h = 40;
    this.c = c;
    this.text = text;
  }
  
  public Button(Position pos, int w, int h, Command c, int value, String text) {
    this.pos = pos;
    this.w = w;
    this.h = h;
    this.c = c;
    this.value = value;
    this.text = text;
  }
  
  public Button(Position pos, int w, int h, Command c, int value, String text, boolean active) {
    this.pos = pos;
    this.w = w;
    this.h = h;
    this.c = c;
    this.value = value;
    this.text = text;
    this.active = active;
  }
  
  public boolean isMouseWithin() {
    return active &&
           mouseX > pos.getX() && mouseX < pos.getX() + w &&
           mouseY > pos.getY() && mouseY < pos.getY() + h &&
           text != "";
  }
  
  public Command getCommand() { return c; }
  public int getValue() { return value; }
  public boolean isPressed() { return pressed; }
  public boolean isActive() { return active; }
  
  public void setPos(Position pos) { this.pos = pos; }
  public void setX(int x) { pos.setX(x); }
  public void setY(int y) { pos.setY(y); }
  public void setCommand(Command c) { this.c = c; }
  public void setValue(int value) { this.value = value; }
  public void setText(String text) { this.text = text; }
  public void setTextColor(Color textColor) { this.textColor = textColor; }
  
  public void display() {
    strokeWeight(1);
    if (text != "")
    {
      if (active) {
        stroke(pressed ? 200 : 100);
        fill(pressed ? 100 : 200);
      }
      else {
        stroke(100, 100);
        fill(200, 100);
      }
      rect(pos.getX(), pos.getY(), w, h); // w90 h40
      if (active) {
        textColor.setFill();
      }
      else {
        textColor.setFill(100);
      }
      textAlign(CENTER);
      textSize((float)h * 0.75);
      text(text, pos.getX() + (float)w / 2, pos.getY() + (float)h * 0.75);
      pressed = false;
    }
  }
  
  public void toggle() { pressed = !pressed; }
  public void activate() { active = true; }
  public void deactivate() { active = false; }
}
