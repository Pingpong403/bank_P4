class GameControl {
  // General attributes
  private Phase currentPhase;
  private Vector<Player> players;
  private Vector<Player> playersToRemove = new Vector<Player>();
  private Vector<Button> gameButtons;
  private Vector<Button> buttonsToRemove = new Vector<Button>();
  private boolean transitioning = true;
  
  // Phase attributes
  private String currentName = "";
  private int round = 0;
  private int bank = 0;
  private int inputAmt = 0;
  
  // Misc attributes
  private Message message = new Message();
  private Vector<Action> actionsThisRound = new Vector<Action>();
  private Vector<Die> dice = new Vector<Die>();
  private boolean diceShow = false;
  private Button hiddenDiceValue = new Button(new Position(-1000, -1000), Command.diceValue, "");
  private Button hiddenDiceSeven = new Button(new Position(-1000, -1000), Command.seven, "");
  private Button hiddenDiceDoubles = new Button(new Position(-1000, -1000), Command.doubles, "");
  
  public GameControl() {
    currentPhase = Phase.playerEntry;
    players = new Vector<Player>();
    gameButtons = new Vector<Button>();
    dice.add(new Die(new Position(390, 300), new Color(rand.nextInt(0, 256), rand.nextInt(0, 256), rand.nextInt(0, 256))));
    dice.add(new Die(new Position(510, 300), new Color(rand.nextInt(0, 256), rand.nextInt(0, 256), rand.nextInt(0, 256))));
  }
  
  private void addPlayer(String name) {
    int i = players.size();
    players.add(new Player(name, i));
  }
  
  public void interact() {
    // Messages should not carry over phases.
    if (transitioning) {
      message.setTimeLeft(0);
    }
    
    // The following cases control interaction during each specific phase.
    switch (currentPhase) {
      case playerEntry:
        if (transitioning) {
          // Add the play button
          Button playButton = new Button(new Position(465, 400), 70, 30, Command.start, 0, "Start");
          gameButtons.add(playButton);
          
          transitioning = false;
        }
        
        // ENTER to add a name
        if (keyCode == ENTER && keyReady) {
          if (currentName.trim() != "") {
            addPlayer(currentName.trim());
            currentName = "";
          }
          else {
            message.flash("Please type a name!");
          }
          keyReady = false;
        }
        // BACKSPACE to delete the last letter typed
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
          // Clear all the game buttons and add the number, undo, and dice buttons.
          gameButtons.clear();
          gameButtons.addAll(getNumberButtons());
          gameButtons.add(getUndoButton());
          gameButtons.add(getShowDiceButton());
          gameButtons.add(getRollDiceButton());
          gameButtons.add(getNewDiceButton());
          
          // Clear the undo queue.
          actionsThisRound.clear();
          
          if (round == 0) {
            // Change removePlayer buttons to playerBank buttons and reset scores.
            for (Player player : players) {
              player.getPlayerButton().setCommand(Command.playerBank);
              player.getPlayerButton().setText("$$");
            }
            // This allows for multiple games without having to restart the simulation.
            for (Player player : players) {
              player.setScore(0);
            }
          }
          else {
            // Reactivate all the buttons we need to reactivate.
            for (Button gameButton : gameButtons) {
              // All game buttons with a value of 0 (specifically the Doubles and all dice buttons) stay deactivated.
              if (gameButton.getValue() != 0) {
                gameButton.activate();
              }
              // The number 7 button will be red if we just restarted the game from round 15.
              if (gameButton.getValue() == 7) {
                gameButton.setTextColor(new Color(0));
              }
            }
          }
          // No one starts the new round banked. Also, we need to reactivate the players' buttons.
          for (Player player : players) {
            player.setBanked(false);
            player.getPlayerButton().activate();
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
        
        // Check if everyone has banked.
        boolean everyoneBanked = true;
        for (Player player : players) {
          if (!player.hasBanked()) {
            everyoneBanked = false;
          }
        }
        // If so, on to the next round!
        if (everyoneBanked) {
          currentPhase = Phase.betweenRounds;
          transitioning = true;
        }
        break;
      case betweenRounds:
        if (transitioning) {
          // Deactivate all buttons except for Undo, preparing for the next round.
          for (Player player : players) {
            player.getPlayerButton().deactivate();
          }
          for (Button button : gameButtons) {
            if (button.getCommand() != Command.undo) button.deactivate();
          }
          // Add the option to move on to the next round.
          gameButtons.add(getNextRoundButton());
          
          transitioning = false;
        }
        // Nothing to do here but listen to the button presses.
        break;
      case gameDone:
        if (transitioning) {
          // Since the game is done, all that's left is to add the option to play again!
          gameButtons.clear();
          gameButtons.add(getPlayAgainButton(true));
          gameButtons.add(getPlayAgainButton(false));
          
          transitioning = false;
        }
        // Nothing to do here but listen to the button presses.
        break;
      default:
        break;
    }
    
    // Here is everything that happens no matter the phase:
    
    // Listen for mouse presses. Simply holding down the mouse selects a button, but releasing it on a button chooses it.
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
    
    // Dispose of any players or buttons we need to.
    // Not doing it here causes a concurrentModificationException.
    for (Player player : playersToRemove) {
      players.remove(player);
    }
    playersToRemove.clear();
    for (Button button : buttonsToRemove) {
      gameButtons.remove(button);
    }
    buttonsToRemove.clear();
    
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
        if (diceShow) {
          for (Die die : dice) {
            die.drawDie();
          }
        }
        break;
      case betweenRounds:
        fill(0);
        textAlign(CENTER);
        textSize(60);
        text("Round " + (round == 0 ? "1" : String.valueOf(round)) + " over!", 500, 200);
        textSize(40);
        text("Bank: " + String.valueOf(bank), 500, 560);
        if (diceShow) {
          for (Die die : dice) {
            die.drawDie();
          }
        }
        break;
      case gameDone:
        noStroke();
        fill(0);
        textSize(50);
        textAlign(CENTER);
        text("Play Again?", 500, 450);
        break;
      default:
        break;
    }
    
    // Everything that shows no matter the phase:
    
    // Find out who is in the lead.
    boolean playerInLead = false;
    int highestScore = getHighestScore();
    if (highestScore != 0) {
      playerInLead = true;
    }
    // Draw player info.
    textAlign(LEFT);
    textSize(30);
    for (Player player : players) {
      String playerInfo = player.getName();
      // Include their score if it isn't player entry phase.
      if (currentPhase != Phase.playerEntry) {
        playerInfo += " - " + String.valueOf(player.getScore());
      }
      // Each player's info is black, unless they are in the lead (blue).
      Color playerColor = new Color(0);
      if (playerInLead) {
        if (player.getScore() == highestScore) {
          playerColor = new Color(0, 0, 255);
        }
      }
      playerColor.setFill();
      text(playerInfo, 45, 35 + (player.getPosition() * 35));
    }
    
    // Display all the game and player buttons.
    for (Button button : gameButtons) {
      button.display();
    }
    for (Player player : players) {
      player.getPlayerButton().display();
    }
    
    // Display the message.
    message.displayMessage();
  }
  
  private void doButtonAction(Button b) {
    // Each button action is controlled here when the player chooses its corresponding button.
    switch (b.getCommand()) {
      case start:
        // Determine if we can move on from the player entry phase. Display error message if needed.
        if (players.size() > 0) {
          currentPhase = Phase.play;
          transitioning = true;
        }
        else {
          message.flash("Please add at least one player before starting!");
        }
        // The "Finish Game" button sends us here as well, so handle that case.
        if (round == 15) {
          currentPhase = Phase.gameDone;
          transitioning = true;
        }
        break;
      case removePlayer:
        // Remove the player associated with their button.
        playersToRemove.add(players.get(b.getValue()));
        
        // All players underneath need their positions, values, and heights adjusted.
        for (int i = b.getValue() + 1; i < players.size(); i++) {
          players.get(i).setPosition(i - 1);
          players.get(i).getPlayerButton().setValue(i - 1);
          int y = 10 + ((i - 1) * 35);
          players.get(i).getPlayerButton().setY(y);
        }
        break;
      case diceValue:
        // Increase inputAmt now rather than later.
        inputAmt++;
        
        // If we have not already done three inputs, then 7 is a special case. Otherwise add the value to the bank.
        if (inputAmt < 4 && b.getValue() == 7) {
          bank += 70;
        }
        else {
          bank += b.getValue();
        }
        
        // Fix button appearance/functionality if we have just undone our 3rd action.
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
        
        // This action can be undone.
        actionsThisRound.add(new Action(Command.diceValue, b.getValue()));
        break;
      case doubles:
        // Very simple action.
        inputAmt++;
        bank *= 2;
        
        // This action can be undone.
        actionsThisRound.add(new Action(Command.doubles, 0));
        break;
      case seven:
        // Immediately advance phases and deny bank actions.
        currentPhase = Phase.betweenRounds;
        for (Player player : players) {
          player.getPlayerButton().deactivate();
        }
        transitioning = true;
        
        // This action can be undone.
        actionsThisRound.add(new Action(Command.seven, 0));
        break;
      case undo:
        undoAction();
        break;
      case playerBank:
        // Add current bank to player's score, bank them, and deactivate their button.
        players.get(b.getValue()).addScore(bank);
        players.get(b.getValue()).bank();
        players.get(b.getValue()).getPlayerButton().deactivate();
        
        // This action can be undone.
        actionsThisRound.add(new Action(Command.playerBank, b.getValue()));
        break;
      case restart:
        // A value of 0 means we'll be entering new players.
        if (b.getValue() == 0) {
          currentPhase = Phase.playerEntry;
          transitioning = true;
          gameButtons.clear();
          // Revert players back to their player entry states, keeping their scores.
          for (Player player : players) {
            player.getPlayerButton().setText("X");
            player.getPlayerButton().setCommand(Command.removePlayer);
            player.getPlayerButton().activate();
          }
        }
        // A value of 1 means we'll be playing again with the same players.
        else if (b.getValue() == 1) {
          currentPhase = Phase.play;
          transitioning = true;
        }
        round = 0;
        break;
      case toggleDice:
        // We are brute-forcing this toggling to ensure the "Toggle Dice" and other dice buttons stay in phase with each other.
        if (!diceShow) {
          diceShow = true;
          for (Button gameButton : gameButtons) {
            if (gameButton.getCommand() == Command.rollDice ||
                gameButton.getCommand() == Command.newDice) {
              gameButton.activate();
            }
          }
        }
        else {
          diceShow = false;
          for (Button gameButton : gameButtons) {
            if (gameButton.getCommand() == Command.rollDice ||
                gameButton.getCommand() == Command.newDice) {
              gameButton.deactivate();
            }
          }
        }
        break;
      case rollDice:
        // Here we will be treating the dice (and the values they roll) as if they are buttons we press.
        int sum = 0;
        for (Die die : dice) {
          die.roll();
          sum += die.getValue();
        }
        // Only two special cases past 3 inputs:
        // a seven is rolled,
        if (sum == 7 && inputAmt > 2) {
          doButtonAction(hiddenDiceSeven);
        }
        // or doubles are rolled.
        else if (dice.get(0).getValue() == dice.get(1).getValue() && inputAmt > 2) {
          doButtonAction(hiddenDiceDoubles);
        }
        // Otherwise, we just add the value shown on the dice.
        else {
          hiddenDiceValue.setValue(sum);
          doButtonAction(hiddenDiceValue);
        }
        break;
      case newDice:
        dice.clear();
        dice.add(new Die(new Position(390, 300), new Color(rand.nextInt(0, 256), rand.nextInt(0, 256), rand.nextInt(0, 256))));
        dice.add(new Die(new Position(510, 300), new Color(rand.nextInt(0, 256), rand.nextInt(0, 256), rand.nextInt(0, 256))));
        break;
      default:
        break;
    }
  }
  
  
  // ALL THE "GET _ BUTTON(S)" METHODS
  private Vector<Button> getNumberButtons() {
    Vector<Button> buttons = new Vector<Button>();
    int buttonWidth = 30;
    int buttonHeight = 30;
    int spacing = 10;
    int startX = (1000 - (5 * buttonWidth  + 4 * spacing)) / 2;
    int startY =   700 - (3 * buttonHeight + 2 * spacing) - 10;
  
    // Procedurally generate the grid of number buttons based on the parameters above.
    for (int i = 2; i <= 12; i++) {
      int alt_i = i - 2;
      int x = startX + (alt_i % 5) * (buttonWidth + spacing);
      int y = startY + (alt_i / 5) * (buttonHeight + spacing);
      buttons.add(new Button(new Position(x, y), buttonWidth, buttonHeight, Command.diceValue, i, String.valueOf(i)));
    }
    // The doubles button will take up the remaining space in the row.
    buttons.add(new Button(
      new Position(
        startX + (11 % 5) * (buttonWidth + spacing),
        startY + (11 / 5) * (buttonHeight + spacing)
      ),
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
      new Position(
        910,
        660
      ),
      80,
      30,
      Command.undo,
      0,
      "Undo"
    );
  }
  
  private Button getShowDiceButton() {
    return new Button(
      new Position(
        840,
        300
      ),
      150,
      30,
      Command.toggleDice,
      0,
      "Toggle Dice"
    );
  }
  
  private Button getRollDiceButton() {
    return new Button(
      new Position(
        840,
        340
      ),
      150,
      30,
      Command.rollDice,
      0,
      "Roll Dice",
      diceShow
    );
  }
  
  private Button getNewDiceButton() {
    return new Button(
      new Position(
        840,
        380
      ),
      150,
      30,
      Command.newDice,
      0,
      "New Dice",
      diceShow
    );
  }
  
  private Button getNextRoundButton() {
    return new Button(
      new Position(
        415,
        460
      ),
      170,
      40,
      Command.start,
      0,
      round == 15 ? "Finish Game" : "Next Round"
    );
  }
  
  private Button getPlayAgainButton(boolean samePlayers) {
    return new Button(
      new Position(
        (samePlayers ? 295 : 505),
        460
      ),
      200,
      40,
      Command.restart,
      (samePlayers ? 1 : 0),
      (samePlayers ? "Same Players" : "New Players")
    );
  }
  
  private void undoAction() {
    if (actionsThisRound.size() == 0) {
      message.flash("No actions to undo!");
    }
    else {
      Action latestAction = actionsThisRound.lastElement();
      // This will remove any dummy actions that may make it into the queue.
      while (latestAction.getCommand() == Command.diceValue && latestAction.getValue() == 0) {
        actionsThisRound.remove(latestAction);
        if (actionsThisRound.size() == 0) {
          message.flash("No actions to undo!");
          break;
        }
        latestAction = actionsThisRound.lastElement();
      }
      // Only the diceValue, doubles, seven, and playerBank actions can be undone. Double-enforce that here.
      switch (latestAction.getCommand()) {
        case diceValue:
          // value: the value to be subtracted
          
          // Remove the value from the bank and remove an input. A seven rolled is the only exception here.
          if (latestAction.getValue() == 7) bank -= 70;
          else bank -= latestAction.getValue();
          inputAmt--;
          break;
        case doubles:
          // value: unnecessary
          
          // Simply divide the bank by half and remove an input.
          bank /= 2;
          inputAmt--;
          break;
        case seven:
          // value: unnecessary
          
          // The "seven" command always ends the current round and can only happen after 3 inputs.
          currentPhase = Phase.play;
          for (Player player : players) {
            // Only players who didn't bank before the seven can bank after this undo.
            if (!player.hasBanked()) {
              player.getPlayerButton().activate();
            }
          }
          for (Button gameButton : gameButtons) {
            // Reactivate buttons that were deactivated during the "seven" action and need to be reactivated.
            // 2 and 12 can only be used when the "seven" action can't be made.
            if (gameButton.getValue() != 2 && gameButton.getValue() != 12) {
              gameButton.activate();
            }
          }
          break;
        case playerBank:
          // value: player to un-bank
          
          // If this was the last player to bank, get the phase back to play and reactivate the necessary buttons.
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
          message.flash("Error undoing action...");
          break;
      }
      // If we just undid the 3rd action, fix buttons.
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
      // Remove this action from the queue.
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
