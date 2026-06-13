# Prey vs Predator

Balatro-like card game

# Goal

- Player has total score
- Player has total HP
- Player plays rounds Each round
- a few predator cards are generated
- player hand is generated - 10 cards
- player has 3 discards of up to 3 cards, those are refilled back with new same
  amount of cards
- player can put up to 5 cards from hand to table
- after player confirms selection, it resolves to a Pocker deck. prey kind -
  water, land, air - is used as suit, and each has a number (one is 1/max - ace)
- predators also have scores, predator total = sum, player total = deck outcome.
  then we compute 0-50 "bloodlust" points "for each eaten prey". if player score
  is higher it means all prey got away, no bloodlust -> predators don't bite the
  Player. if it's higher for predators, means they ate some prey, and got some
  bloodlast. 0 = no bloodlast, 50 = totally ate everybody (e.g. max played suit
  is high card being 1). then bloodlust points are taken from the Player hp and
  we go to next round. total points are getting player score regardless
- game finishes when player is bitten to death by predators
