// The sole purpose of this class is to allow me to easily manipulate a player's score.
class Score {
  private int score;
  
  public Score() {
    score = 0;
  }
  
  public int getScore() { return score; }
  
  public void setScore(int score) { this.score += score; }
  
  public void addScore(int amt) { score += amt; }
}
