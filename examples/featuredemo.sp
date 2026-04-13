// A compact feature showcase for ScriptPoker.

define d as deck with jokers shoes 2 back "##" values["A":[11:1], "K":10, "H":2] remove ["XL"]
define p1 as hand
define p2 as hand
define stash as pile
define highscores as scoreboard ascending
define numbers as array of integer
define hand_sum as integer
define best_name as string
define best_score as integer
define i as integer
define ok as boolean
define label as string

function add_bonus(base as integer, bonus as integer) returns integer {
  return base + bonus
}

procedure announce(msg as string) {
  display msg
}

randomize with 7
put [2, 4, 6] into numbers
put 8 into numbers[count of numbers + 1]

{
  define block_sum as integer
  put 99 into block_sum
  display "Block total: " & block_sum
}

shuffle d
deal 2 to all hands
draw 1 to stash
take random from d to stash

display "P1: " & show p1
display "P2: " & show p2 revealing 1
display "Stash size: " & count of stash
display "First P1 card: " & card 1 of p1
display "First P1 rank/suit: " & rank of card 1 of p1 & "/" & suit of card 1 of p1
display "First P1 values: " & value of card 1 of p1 & "/" & value high of card 1 of p1 & "/" & value low of card 1 of p1

move 3 random top 10 from d to discard
display "Discard: " & show discard
bury all randomly from discard to d

move all "A" from d to discard
display "Moved aces: " & count of discard
bury all from discard randomly to d

put true into ok
deal 500 to p1 on error {
  display "Safe deal failure."
  put false into ok
}

if ok {
  display "Unexpected success."
} else {
  display "Continuing after ON ERROR."
}

put add_bonus(total of p1, 5) into hand_sum
announce("Boosted total: " & hand_sum)

examine {
  case check p1 for pattern(rank(2)) {
    put "P1 has a pair." into label
  }
  case total high of p1 threshold 21 > total high of p2 threshold 21 {
    put "P1 is ahead." into label
  }
  otherwise {
    put "No pair detected." into label
  }
}

display label
display "Aces high in P1: " & aces high of p1 threshold 21

put 1 into i
while true {
  if i > count of numbers {
    exit loop
  }
  display "numbers[" & i & "] = " & numbers[i]
  put i + 1 into i
}

put "Alice", total of p1 into highscores
put "Bob", total of p2 into highscores
put entry 1 of highscores into best_name, best_score
display "Best score: " & best_name & " -> " & best_score

move all from p1 to discard
move all from p2 to stash
display "Before recover: " & count of d & "/" & count of discard & "/" & count of stash
recover d
display "After recover: " & count of d & "/" & count of discard & "/" & count of stash
