define d as deck with values["J":10,"Q":10,"K":10,"A":[11:1]]
define player_name as string

define player as hand
define dealer as hand

//define discard as pile

define choice as string
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

//testing stuff

define i as integer

put 1 into i
while i <= 3 {
  shuffle d
  deal 1 to player
  put i + 1 into i
  display "Player hand: " & show player & " Total: " & hand_total(player) & " Blackjack: " & is_blackjack(player) & " Busted: " & is_busted(player)
}


