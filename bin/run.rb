require 'pry'
require_relative '../config/environment'


#p Baccarat.wager
# testing round 1 and 2
# puts "Round 1"
# Baccarat.player_round_one
# Baccarat.banker_round_one
# Baccarat.winner

# puts "\n\n\nSecond round"
# Baccarat.player_round_two
# Baccarat.banker_round_two

#Baccarat.winner

#binding.pry


game = Baccarat.new
game.run

#binding.pry

#Game.card_revalue

# deck = DeckOfCards.new
# deck.shuffle
# p deck
#p Game.player_hand
# deck = Game.deckofcards
#deck.shuffle
#binding.pry
