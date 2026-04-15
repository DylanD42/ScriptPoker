define library as deck with values["J":10,"Q":10,"K":10,"A":[11:1]]
define player_name as string
define player_hand as hand
define dealer_hand as hand
define choice as string

define bid as integer
define score as integer
define hands_played as integer
define hands_won as integer
define percentage as integer
define dealer_draw_count as integer

function blackjacked(test_hand as hand) returns boolean {
  return total of test_hand = 21 and count of test_hand = 2
}

function soft(test_hand as hand) returns boolean {
    return aces high of test_hand threshold 17 > 0
}


procedure playonehand() {

  display "\n<Setting up for a new hand>"
  recover library
  shuffle library
  deal 2 to all hands

  display "\nDealer's Hand: " & show dealer_hand revealing 1 & " showing a total of " & total of dealer_hand revealing 1

  while total of player_hand <= 21 {

    display player_name & "'s Hand: " & show player_hand & " for a total of " & total of player_hand

    prompt "\nChoose hit or stay? (H/S) " into choice

    examine {
      case choice = "S" or choice = "s" {
        exit loop
      }
      case choice = "H" or choice = "h" {
        deal to player_hand
      }
      otherwise {
        display "Invalid input: " & choice
      }
    }
  }

  put 0 into dealer_draw_count
  if not blackjacked(player_hand) {
    while total of dealer_hand < 16 or (soft(dealer_hand) and total of dealer_hand = 17) {
      deal to dealer_hand
      put dealer_draw_count + 1 into dealer_draw_count
    }
  }

  if dealer_draw_count > 0 { 
    display "\nDealer draws " & dealer_draw_count & " card(s)." 
  }

  display "\n<Results>"
  display "Dealer's Hand: " & show dealer_hand & " for a total of " & total of dealer_hand
  display player_name & "'s Hand: " & show player_hand & " for a total of " & total of player_hand & "\n"
  

  examine {
    case total of player_hand > 21 {
      display "Player busts, Dealer wins."
      put score - bid into score
    }
    case blackjacked(player_hand) and not blackjacked(dealer_hand) {
      display "Player blackjacks!"
      put score + (bid * 3 div 2) into score
      put hands_won + 1 into hands_won
    }  
    case total of player_hand = total of dealer_hand {
      display "Tie, game is a push."
    }
    case total of dealer_hand > 21 {
      display "Dealer busts, Player wins."
      put score + bid into score
      put hands_won + 1 into hands_won
    }
    case total of player_hand > total of dealer_hand {
      display "Player wins by points."
      put score + bid into score
      put hands_won + 1 into hands_won
    }
    otherwise {
      display "Dealer wins by points."
      put score - bid into score
    }
  }
  
  put hands_played + 1 into hands_played

}

put 100 into score
put 10 into bid

display ""
display "< < <  Simplified Blackjack  |  Powered by ScriptPoker  > > >"
display ""
prompt "Please enter your name: " into player_name

while true and score >= bid {

  if hands_played > 0 { 
    put (100 * hands_won) div hands_played into percentage
  } 

  display "\nScore: " & score & "   Played: " & hands_played & "   Won: " & hands_won & "   Percent: " & percentage & "%"

  prompt "\n" & player_name & ", do you want to bid " & bid & " pts to play a hand? (Y/N) " into choice
  examine {
    case choice = "Y" or choice = "y" {
      playonehand()
    }
    case choice = "N" or choice = "n" { 
      exit loop 
      }
    otherwise { 
      display "* Invalid Input: " & choice 
      }
  }
}

if score < bid {
  display "\nYou do not have enough points to bid."
  display "The house always wins... eventually."
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

put player_name, score into scores

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
display "\nThanks for playing, " & player_name & "!\n"

