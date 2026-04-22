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
define dealer_hand_size as integer

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
  if dealer_hand_size > 2 {
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
    if count of d < 3 {
        move all from discard to d
        shuffle d
        recover d
        
    }
}

procedure dealer_turn(){
  put 2 into dealer_hand_size
  while hand_total(dealer) < 17 {
    put (dealer_hand_size + 1) into dealer_hand_size
    show_table()
    deal to dealer
  }
}

procedure end_round(){
  define player_total as integer
  define dealer_total as integer

  put hand_total(player) into player_total
  put hand_total(dealer) into dealer_total
  examine{
    case is_blackjack(player){
      display "Blackjack! You win! +20 points"
      change_points(20)
    }
    case is_busted(player) {
      display "You busted! Dealer wins. -10 points"
      change_points(-10)
    }
    case is_busted(dealer) {
      display "Dealer busted! You win! +15 points"
      change_points(15)
    }
    case player_total > dealer_total {
      display "You win with " & player_total & " against the dealer's " & dealer_total & "! +15 points"
      change_points(15)
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

define file as csv delimiter "|"
define scores as scoreboard
define hs_name as string 
define hs_score as integer
put "highscores.txt" into file
open file for read

while not end of file {
  read hs_name, hs_score from file
  put hs_name, hs_score into scores
}
close file

put name, score into scores

define i as integer
put 1 into i
display "\n<HIGH SCORES>"
while i <= 10 and i <= count of scores {
  put entry i of scores into hs_name, hs_score
  display hs_name & ": " & hs_score
  put i + 1 into i
} 
put "highscores.txt" into file
open file for write

put 1 into i
while i <= 10 and i <= count of scores {
  put entry i of scores into hs_name, hs_score
  write hs_name, hs_score to file
  put i + 1 into i
} 
close file
display "\nThanks for playing, " & name & "!\n"


