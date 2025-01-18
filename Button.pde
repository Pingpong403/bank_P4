class Button {
  private int x;
  private int y;
  private int w;
  private int h;
  private Command c;
  private int value = 0;
  private String text = "";
  private boolean pressed = false;
  private boolean active = true;
  private Color textColor = new Color(0);
  
  public Button() {
    x = 0;
    y = 0;
    w = 90;
    h = 40;
    c = Command.start;
  }
  
  public Button(int x, int y, Command c, String text) {
    this.x = x;
    this.y = y;
    w = 90;
    h = 40;
    this.c = c;
    this.text = text;
  }
  
  public Button(int x, int y, int w, int h, Command c, int value, String text) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.c = c;
    this.value = value;
    this.text = text;
  }
  
  public Button(int x, int y, int w, int h, Command c, int value, String text, boolean active) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.c = c;
    this.value = value;
    this.text = text;
    this.active = active;
  }
  
  public boolean isMouseWithin() {
    if (active && mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h && text != "")
    {
      return true;
    }
    return false;
  }
  
  public Command getCommand() { return c; }
  public int getValue() { return value; }
  public boolean isPressed() { return pressed; }
  public boolean isActive() { return active; }
  
  public void setY(int y) {
    this.y = y;
  }
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
      rect(x, y, w, h); // w90 h40
      if (active) {
        textColor.setFill();
      }
      else {
        textColor.setFillA(100);
      }
      textAlign(CENTER);
      textSize((float)h * 0.75);
      text(text, x + (float)w / 2, y + (float)h * 0.75);
      pressed = false;
    }
  }
  
  public void toggle() { pressed = !pressed; }
  public void activate() { active = true; }
  public void deactivate() { active = false; }
}
