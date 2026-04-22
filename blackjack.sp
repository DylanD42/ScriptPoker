define d as deck with values["J":10,"Q":10,"K":10,"A":[11:1]]
define player as hand
define dealer as hand
define playing as boolean
define roundover as boolean
define score as integer
define bet as integer
define dealer_draw_count as integer
define highscores as scoreboard
define name as string
define dealer_revealed as boolean

put 100 into score //starting score for player, can be used for betting and tracking wins/losses
put 10 into bet
function hand_total(h as hand) returns integer {
  return total of h threshold 21
  // This function calculates the total value of a hand, treating Aces as 11 or 1 as needed to avoid busting.
}

function is_blackjack(h as hand) returns boolean {
  return hand_total(h) = 21
  // This function checks if a hand is a blackjack.
}

function is_busted(h as hand) returns boolean {
  return hand_total(h) > 21
  // This function checks if a hand has busted (total value exceeds 21).
}

function continue_game() returns boolean {
  define choice as string
  display ""
  if(score >= bet ){
  prompt "Would you like to play a round of blackjack? (Y/N)" into choice
  examine {
    case choice = "N" OR choice = "n" OR choice = "no" OR choice = "No" OR choice = "NO" {
      return false
    }
    case choice = "Y" OR choice = "y" OR choice = "Yes" OR choice = "yes" {
      return true
    }
    otherwise {
      display "Invalid choice. Please enter Y or N." & choice
      }
    }
  } else {
    display "You don't have enough points to continue playing. Game over!"
    return false
  }
}

procedure change_points(num as integer){
  put (score+num) into score
}

procedure show_table() {
//what gets shown each round
  display ""
  display "<DEALER>"
  if dealer_revealed {
    display show dealer
  } else {
    display show dealer revealing 1 
  }
  display ""
  display "<" & name & ": " & score & ">"
  display show player
  display "Total: " & hand_total(player)
  display ""
}


// may end up making this be a live thing that updates as the player hits, but for now just a function to show the current hand and total
procedure init_deal() {
    put false into dealer_revealed
    deal 2 to player
    deal 2 to dealer
}

procedure clear_table(){
    if count of player > 0 {
        move all from player to discard
    }
    if count of dealer > 0 {
        move all from dealer to discard
    }
}

procedure reset_deck(){
        move all from discard to d
        shuffle d
        recover d
}

procedure dealer_turn(){
  put true into dealer_revealed
  show_table()
  while hand_total(dealer) < 17 {
    deal to dealer
    show_table()
  }
}

procedure end_round(){
  define player_total as integer
  define dealer_total as integer

  put hand_total(player) into player_total
  put hand_total(dealer) into dealer_total
  examine{
    case is_blackjack(player) AND NOT is_blackjack(dealer){
      display "Blackjack! You win! +15 points"
      change_points(15)
    }
    case is_blackjack(dealer) AND NOT is_blackjack(player){
      display "Dealer has blackjack! Dealer wins. -10 points"
      change_points(-10)
    }
    case is_blackjack(player) AND is_blackjack(dealer){
      display "Both have blackjack! It's a push. No points awarded."
    }
    case is_busted(player) {
      display "You busted! Dealer wins. -10 points"
      change_points(-10)
    }
    case is_busted(dealer) {
      display "Dealer busted! You win! +10 points"
      change_points(10)
    }
    case player_total > dealer_total {
      display "You win with " & player_total & " against the dealer's " & dealer_total & "! +10 points"
      change_points(10)
    }
    case dealer_total > player_total {
      display "Dealer wins with " & dealer_total & " against your " & player_total & ". -10 points"
      change_points(-10)
    }
    otherwise {
      display "It's a push with both you and the dealer at " & player_total & ". No points awarded."
    }
  }
}


procedure player_turn(){
  define done as boolean
  define choice as string
  put false into done
  show_table()
  if is_blackjack(player) {
    put true into done
  }
  while NOT done {
    prompt "Do you want to Hit (H) or Stand (S)?" into choice
      examine{
        case choice = "H" OR choice = "h" OR choice = "Hit" OR choice = "hit" {
          deal to player
          show_table()
        }
        case choice = "S" OR choice = "s" OR choice = "Stand" OR choice = "stand" {
          put true into done
        }
        otherwise {
          display "Invalid choice. Please enter H or S." & choice
      }
    }
    
    if is_busted(player) {
      put true into done
      }
    if is_blackjack(player) {
      put true into done
      }
  }
}


//main gameplay loop
put true into playing
prompt "Welcome to Blackjack! Please enter your name:" into name
while playing {
  clear_table()
  reset_deck()
  init_deal()
  player_turn()
  dealer_turn()
  end_round()
  put continue_game() into playing
}

// Scoreboard
define high_scores as scoreboard
define scores_file as csv
put "highscores.csv" into scores_file

// Scoreboard TMP variables
define i as integer
define player_placed as boolean
define name_tmp as string
define score_tmp as integer

// Read in high scores file contents
open scores_file for read
iterate i from 1 to 10 {

    if end of scores_file{
        put "", 0 into high_scores
    } else{
        read name_tmp, score_tmp from scores_file
        put name_tmp, score_tmp into high_scores
    }
}
close scores_file

// Copy the high scores board to include the user, if they made the board
define new_high_scores as scoreboard
put 1 into i
put FALSE into player_placed
while i < 11 {

    put entry i of high_scores into name_tmp, score_tmp

    // Player made leaderboard
    if score > score_tmp AND NOT player_placed {
        display "-------------------------------------------------"
        display "Congrats! You've made the leaderboard!"
        display "Your final cash was $" & score
        prompt "(Press ENTER to continue)" into name_tmp
        display "-------------------------------------------------"
        put name, score into new_high_scores
        put TRUE into player_placed
    } else {
        put name_tmp, score_tmp into new_high_scores
        put i + 1 into i
    }
}

// Print out and save the leaderboard to file
open scores_file for write
display "-------------------------------------------------"
display "                   Leaderboard                   "
display ""
iterate i from 1 to 10 {

  put entry i of new_high_scores into name_tmp, score_tmp
  write name_tmp, score_tmp to scores_file

  if score = 0 {
      display "#" & i & ": "
  } else {
      display "#" & i & ": " & name_tmp
      display "    Score: " & score_tmp
  }
}
display "-------------------------------------------------"
close scores_file
display "Final Cash: $" & score
display "Thanks for Playing!"
