class Position {
  private int x;
  private int y;
  
  public Position() {
    x = 0;
    y = 0;
  }
  
  public Position(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  public Position(Position pos) {
    x = pos.getX();
    y = pos.getY();
  }
  
  public int getX() { return x; }
  public int getY() { return y; }
  
  public void setX(int x) { this.x = x; }
  public void setY(int y) { this.y = y; }
  public void setXY(int x, int y) {
    this.x = x;
    this.y = y;
  }
}
