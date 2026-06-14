# Project

- Godot game
- Modern best practices
- Clean code

# Game Goal Overview

Note: this is overview of the game, not a single task

- Player has total score
- Player has total HP
- Player plays rounds Each round
- a few predator cards are generated
- player hand is generated - 10 cards
- player has 3 discards of up to 3 cards, those are refilled back with new same
  amount of cards
- player can put up to 5 cards from hand to table
- after player confirms selection, it resolves to a Poker hand. prey kind -
  water, land, air - is used as suit, and each has a number (one is 1/max -
  ace). note: flushes are not allowed, see scoring
- predators also have scores, predator total = sum, player total = deck outcome.
  then we compute 0-50 "bloodlust" points "for each eaten prey". if player score
  is higher it means all prey got away, no bloodlust -> predators don't bite the
  Player. if it's higher for predators, means they ate some prey, and got some
  bloodlast. 0 = no bloodlast, 50 = totally ate everybody (e.g. max played suit
  is high card being 1). then bloodlust points are taken from the Player hp and
  we go to next round. total points are getting player score regardless
- game finishes when player is bitten to death by predators

## Prey Twist

- Suits matter more than just for hand. Air gets away easier from land, land
  from water and water from air.
- When calculating scores, each prey is modified by each predator: accumulative
  buff against easier suits, debuff against another suit, and no change against
  same suit.
- Outcome: player has to not to just build a strong hand, but to account for
  suit matching.

## Scoring

- Player can play 1-5 prey cards to resolve the round.
- Flushes are too disbalanced, so both royal and regular flushes are not a hand
  here. Suits are used only for prey escape matching.
- Scoring hands are high card, pair, two pair, three of a kind, straight, and
  full house.
- Only cards that belong to the scoring hand enter prey suit resolution. Extra
  selected cards are discarded. High card uses the highest selected card, pair
  uses the pair, two pair uses both pairs, three of a kind uses the three, and
  straight/full house use all cards in the hand.
- Player gets `score_gain = sum(scoring card values) * hand_multiplier` to
  their total score.
- Hand multipliers are high card `x1`, pair `x2`, two pair `x3`, three of a
  kind `x4`, straight `x5`, and full house `x6`.
- Each prey suit resolves separately. Cards first reveal their raw values:
  `base_prey_score = sum(scoring prey values in suit)`.
- Final prey suit score applies the hand multiplier:
  `prey_score = base_prey_score * hand_multiplier`.
- Predator score stays raw and stable:
  `predator_score = sum(predator values)`.
- Predator target score is matchup-weighted:
  `predator_target_score = sum(predator value * matchup_multiplier)`.
- Predator values are not mathematically redistributed between suits. The raw
  predator preview shows predator cards grouped by predator suit and hides zero
  suit rows. When prey are selected, the predator UI switches in realtime to
  played prey target lanes, hides unplayed suit rows, and shows the predator
  escape target for each compared lane:
  `predator_target_score = sum(predator value * matchup_multiplier)`.
- Before play, prey score UI shows only `$hand +$score`.
- During resolution, prey suit rows expand from zero, increment by raw scoring
  card values, then settle on final multiplied prey scores.
- Predator score UI format: `$hand`, then `$suit $value`.
- Matchup multipliers:
  - prey suit beats predator suit: `0.75`
  - same suit: `1.0`
  - predator suit beats prey suit: `1.25`
- Suit cycle: air beats land, land beats water, water beats air.
- If `prey_score >= predator_target_score`, prey of that suit escape.
- If `prey_score < predator_target_score`, prey of that suit are eaten:
  `damage = ceil(((predator_target_score - prey_score) / predator_target_score) * 12) * eaten_prey_count`.
- Total round damage is the sum of damage from each failed suit.

# Assistant requirements

- Don't run godot validations
- Write only what you were tasked to
- Strictly follow existing structure, patterns, ideas and naming
