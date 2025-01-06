class GameControl {
  private Phase currentPhase;
  private Vector<Player> players;
  private Vector<Player> playersToRemove = new Vector<Player>();
  private Vector<Button> gameButtons;
  private Vector<Button> buttonsToRemove = new Vector<Button>();
  private boolean transitioning = true;
  private String currentName = "";
  private int round = 0;
  private int bank = 0;
  private int inputAmt = 0;
  private Message message = new Message();
  private Vector<Action> actionsThisRound = new Vector<Action>();
  
  public GameControl() {
    currentPhase = Phase.playerEntry;
    players = new Vector<Player>();
    gameButtons = new Vector<Button>();
  }
  
  private void addPlayer(String name) {
    int i = players.size();
    players.add(new Player(name, i));
  }
  
  public void interact() {
    if (transitioning) {
      message.setTimeLeft(0);
    }
    switch (currentPhase) {
      case playerEntry:
        if (transitioning) {
          Button playButton = new Button(465, 400, 70, 30, Command.start, 0, "Start");
          gameButtons.add(playButton);
          transitioning = false;
        }
        
        if (keyCode == ENTER && keyReady) {
          if (currentName != "") {
            addPlayer(currentName.trim());
            currentName = "";
          }
          else {
            message.setText("Please type a name!");
            message.refresh();
          }
          keyReady = false;
        }
        if (keyCode == BACKSPACE && keyReady) {
          if (currentName != "") {
            currentName = currentName.substring(0, currentName.length() - 1);
          }
          keyReady = false;
        }
        if (keyPressed && keyReady) {
          currentName += KeyboardHelper.charToStr(key);
          keyReady = false;
        }
        break;
      case play:
        if (transitioning) {
          // Clear all the buttons and add back the undo and dice buttons
          gameButtons.clear();
          gameButtons.addAll(getNumberButtons());
          gameButtons.add(getUndoButton());
          
          // Clear the undo queue
          actionsThisRound.clear();
          
          // Only if going from playerEntry to play, change removePlayer buttons to playerBank buttons
          if (round == 0) {
            for (Player player : players) {
              player.getPlayerButton().setCommand(Command.playerBank);
              player.getPlayerButton().setText("$$");
            }
            // This allows for multiple games without having to restart the simulation
            for (Player player : players) {
              player.setScore(0);
            }
          }
          else {
            // Reactivate all the buttons we need to reactivate
            for (Button gameButton : gameButtons) {
              if (gameButton.getValue() != 0) {
                gameButton.activate();
              }
              if (gameButton.getValue() == 7) {
                gameButton.setTextColor(new Color(0));
              }
            }
            for (Player player : players) {
              player.getPlayerButton().activate();
            }
          }
          // No one starts the new round banked
          for (Player player : players) {
            player.setBanked(false);
          }
          inputAmt = 0;
          bank = 0;
          round++;
          transitioning = false;
        }
        // If we undo an action after the round is over, get rid of the "Next Round" button
        for (Button gameButton : gameButtons) {
          if (gameButton.getCommand() == Command.start) {
            buttonsToRemove.add(gameButton);
          }
        }
        
        boolean everyoneBanked = true;
        for (Player player : players) {
          if (!player.hasBanked()) {
            everyoneBanked = false;
          }
        }
        if (everyoneBanked) {
          currentPhase = Phase.betweenRounds;
          transitioning = true;
        }
        break;
      case betweenRounds:
        if (transitioning) {
          // Deactivate all buttons except for Undo, preparing for the next round
          for (Player player : players) {
            player.getPlayerButton().deactivate();
          }
          for (Button button : gameButtons) {
            if (button.getCommand() != Command.undo) button.deactivate();
          }
          gameButtons.add(getNextRoundButton());
          transitioning = false;
        }
        break;
      default:
        break;
    }
    
    // Everything that happens no matter the phase
    if (mousePressed) {
      for (Button b : gameButtons) {
        if (b.isMouseWithin() && !b.isPressed()){
          b.toggle();
        }
      }
      for (Player player : players) {
        Button b = player.getPlayerButton();
        if (b.isMouseWithin() && !b.isPressed()){
          b.toggle();
        }
      }
    }
    if (mouseChoose) {
      for (Button b : gameButtons) {
        if (b.isMouseWithin()) {
          doButtonAction(b);
          mouseChoose = false;
          break;
        }
      }
      for (Player player : players) {
        Button b = player.getPlayerButton();
        if (b.isMouseWithin()) {
          doButtonAction(b);
          mouseChoose = false;
          break;
        }
      }
    }
    for (Player player : playersToRemove) {
      players.remove(player);
    }
    playersToRemove.clear();
    for (Button button : buttonsToRemove) {
      gameButtons.remove(button);
    }
    playersToRemove.clear();
    message.age();
  }
  
  public void drawGUI() {
    switch (currentPhase) {
      case playerEntry:
        fill(0);
        textAlign(CENTER);
        textSize(25);
        text(currentName, 500, 350);
        textAlign(RIGHT);
        textSize(15);
        text("INSTRUCTIONS\nType in names. Typing is finicky.\nPress 'ENTER' to add a name.\nPress 'Start' to begin.", 990, 635);
        break;
      case play:
        fill(0);
        textAlign(CENTER);
        textSize(60);
        text("Round " + (round == 0 ? "1" : String.valueOf(round)), 500, 200);
        textSize(40);
        text("Bank: " + String.valueOf(bank), 500, 560);
        break;
      case betweenRounds:
        fill(0);
        textAlign(CENTER);
        textSize(60);
        text("Round " + (round == 0 ? "1" : String.valueOf(round)) + " over!", 500, 200);
        textSize(40);
        text("Bank: " + String.valueOf(bank), 500, 560);
        break;
      default:
        break;
    }
    
    // Everything that shows no matter the phase
    textAlign(LEFT);
    textSize(30);
    
    boolean playerInLead = false;
    int highestScore = getHighestScore();
    if (highestScore != 0) {
      playerInLead = true;
      highestScore = getHighestScore();
    }
    for (Player player : players) {
      String playerInfo = player.getName();
      if (currentPhase != Phase.playerEntry) {
        playerInfo += " - " + String.valueOf(player.getScore());
      }
      Color playerColor = new Color(0);
      if (playerInLead) {
        if (player.getScore() == highestScore) {
          playerColor = new Color(0, 0, 255);
        }
      }
      playerColor.setFill();
      text(playerInfo, 45, 35 + (player.getPosition() * 35));
    }
    for (Button button : gameButtons) {
      button.display();
    }
    for (Player player : players) {
      player.getPlayerButton().display();
    }
    message.displayMessage();
  }
  
  private void doButtonAction(Button b) {
    switch (b.getCommand()) {
      case start:
        if (players.size() > 0) {
          currentPhase = Phase.play;
          transitioning = true;
        }
        else {
          message.setText("Please add at least one player before starting!");
          message.refresh();
        }
        break;
      case removePlayer:
        // Remove the player and the button associated with them
        playersToRemove.add(players.get(b.getValue()));
        
        // All other buttons underneath need their heights adjusted 
        for (int i = b.getValue() + 1; i < players.size(); i++) {
          players.get(i).getPlayerButton().setValue(i - 1);
          int y = 10 + ((i - 1) * 35);
          players.get(i).getPlayerButton().setY(y);
        }
        break;
      case diceValue:
        // Increase inputAmt now rather than later
        inputAmt++;
        if (inputAmt < 4) {
          if (b.getValue() == 7) bank += 70;
          else bank += b.getValue();
        }
        else {
          bank += b.getValue();
        }
        
        // We need to activate/deactivate buttons here
        if (inputAmt >= 3) {
          for (Button gameButton : gameButtons) {
            if (gameButton.getValue() == 2 || gameButton.getValue() == 12) {
              gameButton.deactivate();
            }
            else if (gameButton.getValue() == 7) {
              gameButton.setCommand(Command.seven);
              gameButton.setTextColor(new Color(255, 0, 0));
            }
            else if (gameButton.getCommand() == Command.doubles) {
              gameButton.activate();
            }
          }
        }
        actionsThisRound.add(new Action(Command.diceValue, b.getValue()));
        break;
      case doubles:
        inputAmt++;
        bank *= 2;
        actionsThisRound.add(new Action(Command.doubles, 0));
        break;
      case seven:
        currentPhase = Phase.betweenRounds;
        for (Player player : players) {
          player.getPlayerButton().deactivate();
        }
        transitioning = true;
        actionsThisRound.add(new Action(Command.seven, 0));
        break;
      case undo:
        undoAction();
        break;
      case playerBank:
        // Add current bank to player's score and deactivate their button
        players.get(b.getValue()).addScore(bank);
        players.get(b.getValue()).bank();
        players.get(b.getValue()).getPlayerButton().deactivate();
        
        actionsThisRound.add(new Action(Command.playerBank, b.getValue()));
        break;
      default:
        break;
    }
  }
  
  private Vector<Button> getNumberButtons() {
    Vector<Button> buttons = new Vector<Button>();
    int buttonWidth = 30;
    int buttonHeight = 30;
    int spacing = 10;
    int startX = (1000 - (5 * buttonWidth + 4 * spacing)) / 2; // O O O O O
    int startY = 700 - 3 * buttonHeight - spacing - 20;        // ...
  
    // grid of number buttons
    for (int i = 2; i <= 12; i++) {
      int alt_i = i - 2;
      int x = startX + (alt_i % 5) * (buttonWidth + spacing);
      int y = startY + (alt_i / 5) * (buttonHeight + spacing);
      buttons.add(new Button(x, y, buttonWidth, buttonHeight, Command.diceValue, i, String.valueOf(i)));
    }
    // doubles button
    buttons.add(new Button(
      startX + (11 % 5) * (buttonWidth + spacing),
      startY + (11 / 5) * (buttonHeight + spacing),
      buttonWidth * 4 + spacing * 3,
      buttonHeight,
      Command.doubles,
      0,
      "DOUBLES",
      false
    ));
    return buttons;
  }
  
  private Button getUndoButton() {
    return new Button(
      910,
      660,
      80,
      30,
      Command.undo,
      0,
      "Undo"
    );
  }
  
  private Button getNextRoundButton() {
    return new Button(
      425,
      460,
      150,
      40,
      Command.start,
      0,
      "Next Round"
    );
  }
  
  private void undoAction() {
    if (actionsThisRound.size() == 0) {
      message.setText("No actions to undo!");
      message.refresh();
    }
    else {
      Action latestAction = actionsThisRound.lastElement();
      // diceValue, doubles, seven, and playerBank can be undone
      switch (latestAction.getCommand()) {
        case diceValue:
          if (latestAction.getValue() == 7) bank -= 70;
          else bank -= latestAction.getValue();
          inputAmt--;
          break;
        case doubles:
          bank /= 2;
          inputAmt--;
          break;
        case seven:
          currentPhase = Phase.play;
          for (Player player : players) {
            if (!player.hasBanked()) {
              player.getPlayerButton().activate();
            }
          }
          for (Button gameButton : gameButtons) {
            if (gameButton.getValue() != 2 && gameButton.getValue() != 12) {
              gameButton.activate();
            }
          }
          break;
        case playerBank:
          // If this was the last player to bank, get the phase back to play and reactivate buttons
          if (currentPhase == Phase.betweenRounds) {
            currentPhase = Phase.play;
            for (Button gameButton : gameButtons) {
              if (inputAmt < 3) {
                if (gameButton.getValue() != 0) {
                  gameButton.activate();
                }
              }
              else {
                if (gameButton.getValue() != 2 && gameButton.getValue() != 12) {
                  gameButton.activate();
                }
              }
            }
          }
          // Remove the current bank from the player and reactivate their button
          players.get(latestAction.getValue()).addScore(-1 * bank);
          players.get(latestAction.getValue()).getPlayerButton().activate();
          players.get(latestAction.getValue()).setBanked(false);
          break;
        default:
          message.setText("Error undoing action...");
          message.refresh();
          break;
      }
      if (inputAmt < 3) {
          for (Button gameButton : gameButtons) {
            if (gameButton.getValue() == 2 || gameButton.getValue() == 12) {
              gameButton.activate();
            }
            else if (gameButton.getValue() == 7) {
              gameButton.setCommand(Command.diceValue);
              gameButton.setTextColor(new Color(0));
            }
            else if (gameButton.getCommand() == Command.doubles) {
              gameButton.deactivate();
            }
          }
      }
      actionsThisRound.remove(latestAction);
    }
  }
  
  private int getHighestScore() {
    int highestScore = 0;
    for (Player player : players) {
      if (player.getScore() > highestScore) {
        highestScore = player.getScore();
      }
    }
    return highestScore;
  }
}
