class Color {
  private int r;
  private int g;
  private int b;
  private int a = 255;
  
  public Color() {
    r = g = b = 0;
  }
  
  public Color(Color c) {
    this.r = c.getR();
    this.g = c.getG();
    this.b = c.getB();
  }
  
  public Color(int value) {
    r = value;
    g = value;
    b = value;
  }
  
  public Color(int r, int g, int b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
  
  public int getR() { return r; }
  public int getG() { return g; }
  public int getB() { return b; }
  public int getValue() {
    return (int)((double)(r + g + b) / 3.0);
  }
  public int getA() { return a; }
  
  public void setR(int r) { this.r = r; }
  public void setG(int g) { this.g = g; }
  public void setB(int b) { this.b = b; }
  public void setValue(int value) {
    r = g = b = value;
  }
  public void setA(int a) { this.a = a; }
  
  public void setStroke() {
    stroke(r, g, b, a);
  }
  
  public void setFill() {
    fill(r, g, b, a);
  }
  
  public void setStroke(int a) {
    stroke(r, g, b, a);
  }
  
  public void setFill(int a) {
    fill(r, g, b, a);
  }
}
