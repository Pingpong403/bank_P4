class Player {
  private String name;
  private int position;
  private int score = 0;
  private boolean banked = false;
  private Button playerButton = new Button();
  private boolean inTheLead = false;
  
  public Player() {
    name = "Player";
    position = 0;
  }
  
  public Player(String name, int position) {
    this.name = name;
    this.position = position;
    int y = 10 + (position * 35);
    playerButton = new Button(10, y, 30, 30, Command.removePlayer, position, "X");
  }
  
  public String getName() { return name; }
  public int getPosition() { return position; }
  public int getScore() { return score; }
  public boolean hasBanked() { return banked; }
  public Button getPlayerButton() { return playerButton; }
  public boolean isInTheLead() { return inTheLead; }
  
  public void setName(String name) { this.name = name; }
  public void setPosition(int position) { this.position = position; }
  public void setScore(int score) { this.score = score; }
  public void setBanked(boolean banked) { this.banked = banked; }
  public void setPlayerButton(Button playerButton) { this.playerButton = playerButton; }
  public void setInTheLead(boolean inTheLead) { this.inTheLead = inTheLead; }
  
  public void updateButtonValue() {
    playerButton.setValue(position);
  }
  public void addScore(int amt) { score += amt; }
  public void bank() { banked = true; }
}
