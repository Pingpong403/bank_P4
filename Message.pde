class Message {
  private String text;
  private int timeLeft = 300;
  
  public Message() {
    text = "";
  }
  
  public Message(String text) {
    this.text = text;
  }
  
  public void age() {
    timeLeft--;
    if (!isActive()) {
      text = "";
    }
  }
  
  public String getText() { return text; }
  
  public void setText(String text) { this.text = text; }
  public void setTimeLeft(int timeLeft) { this.timeLeft = timeLeft; }
  
  public boolean isActive() { return timeLeft > 0; }
  
  public void flash(String text) {
    setText(text);
    refresh();
  }
  private void refresh() { timeLeft = 300; }
  public void displayMessage() {
    textSize(25);
    fill(255, 0, 0);
    textAlign(CENTER);
    text(text, 500, 100);
  }
}
