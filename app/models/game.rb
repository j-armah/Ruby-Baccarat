require 'pry'
require 'deck-of-cards'

class Game < ActiveRecord::Base
    belongs_to :banker
    belongs_to :user

    def value=(value)
        @value = value
    end

    def self.deckofcards
        DeckOfCards.new.shuffle
    end

    def self.value_cards
        new_deck = []
        deck = deckofcards.map{|card| [card.to_s, value:card.value]}
        deck.map do |key, value|
            if key.include?("Jack") || key.include?("Queen") || key.include?("King") || key.include?("10")
                value[:value] = 0
            elsif key.include?("Ace")
                value[:value] = 1
            end
        end
        deck
    end

    # def self.card_revalue
    #     self.deckofcards.cards.each do |card|
    #         if card.rank == "Jack" || card.rank == "Queen" || card.rank == "King" || card.rank == 10
    #             card.value = 0
    #         end
    #     end
    # end

    def self.draw_card
        self.value_cards.sample
    end

    def self.player_hand
        puts "The player draws two cards."
        sleep(1)
        user_card1 = self.draw_card
        user_card2 = self.draw_card
        user_card1_value = user_card1[1][:value]
        user_card2_value = user_card2[1][:value]

        puts "Player's Hand: #{user_card1[0]} #{user_card2[0]}"
        sleep(1)

        player_hand_value = user_card1_value + user_card2_value
        if player_hand_value <= 5 
            puts "The player hand value is #{player_hand_value}, draw again"
            user_card3 = self.draw_card
            user_card3_value = user_card3[1][:value]
            puts "The player draws: #{user_card3[0]}"
            player_hand_value += user_card3_value
            puts "The player hand value is now #{player_hand_value}"
        elsif player_hand_value > 9
            player_hand_value -= 10
            puts "Player hand value over 10, subtract 10"
            puts "Player hand value is now #{player_hand_value}"
        else
            puts "The player will stay, hand value is: #{player_hand_value}"
        end
    end

    def self.banker_hand
        banker_card1 = self.draw_card
        banker_card2 = self.draw_card
        banker_card1_value = banker_card1[1][:value]
        banker_card2_value = banker_card2[1][:value]
    end


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