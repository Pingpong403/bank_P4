class Action {
  private Command c;
  private int value;
  
  public Action() {
    c = Command.diceValue;
    value = 0;
  }
  
  public Action(Command c, int value) {
    this.c = c;
    this.value = value;
  }
  
  public Command getCommand() { return c; }
  public int getValue() { return value; }
}
