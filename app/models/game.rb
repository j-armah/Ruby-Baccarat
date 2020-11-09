require 'pry'
require 'deck-of-cards'

class Game < ActiveRecord::Base
    belongs_to :banker
    belongs_to :user

    def self.deckofcards
        deck = DeckOfCards.new
        deck.shuffle
        deck
    end

    def self.draw_card
        self.deckofcards.draw
    end

    def self.player_hand
        card1 = self.draw_card
        card2 = self.draw_card
        [card1, card2]
    end

    def self.banker_hand
        card1 = self.draw_card
        card2 = self.draw_card
        [card1, card2]
    end




    # Deck of cards
    # change card values
    # shuffle


    # Banker Hand holds value
    # Player Hand holds value

    # method to check value of player hand
    # method to check value of banker hand

    # place bet method, checks users balance

    # draw card method

    # third_draw? if dealer needs to draw another card then use helper method 
    # or another method where dealer draws third card

    # winner method

    # play another game method?


end