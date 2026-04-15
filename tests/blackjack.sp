define d as deck with values["J":10,"Q":10,"K":10,"A":[11:1]]
define player_name as string

define player as hand
define dealer as hand

//define discard as pile


define playing as boolean
define roundover as boolean
define score as integer
define bet as integer
define dealer_draw_count as integer
define highscores as scoreboard


function hand_total(h as hand) returns integer {
  return total of h threshold 21
  // This function calculates the total value of a hand, treating Aces as 11 or 1 as needed to avoid busting.
}

function is_blackjack(h as hand) returns boolean {
  return hand_total(h) = 21
  // This function checks if a hand is a blackjack (two cards totaling 21).
}

function is_busted(h as hand) returns boolean {
  return hand_total(h) > 21
  // This function checks if a hand has busted (total value exceeds 21).
}

function continue_game() returns boolean {
  define choice as string
  display ""
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
}

procedure show_table() {
//what gets shown each round
  display ""
  display "<DEALER>"
  display show dealer revealing 1
  display ""
  display "<PLAYER>"
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
  while hand_total(dealer) < 17 {
    deal to dealer
  }
}

procedure end_round(){
  define player_total as integer
  define dealer_total as integer

  put hand_total(player) into player_total
  put hand_total(dealer) into dealer_total
  examine{
    case is_busted(player) {
      display "You busted! Dealer wins."
    }
    case is_busted(dealer) {
      display "Dealer busted! You win!"
    }
    case player_total > dealer_total {
      display "You win with " & player_total & " against the dealer's " & dealer_total & "!"
    }
    case dealer_total > player_total {
      display "Dealer wins with " & dealer_total & " against your " & player_total & "."
    }
    otherwise {
      display "It's a push with both you and the dealer at " & player_total & "."
    }
  }
}

procedure player_turn(){
  define done as boolean
  define choice as string
  put false into done

  while NOT done {
    prompt "Do you want to Hit (H) or Stand (S)?" into choice
      examine{
        case is_busted(player) {
          display "You busted! Dealer wins."
          put true into done
        }
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
  }
}


//main gameplay loop
put true into playing
display "Welcome to Blackjack! Please enter your name:"
while playing {
  clear_table()
  reset_deck()
  init_deal()
  player_turn()
  dealer_turn()
  end_round()
  put continue_game() into playing
}



