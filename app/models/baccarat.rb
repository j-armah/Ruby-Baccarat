require "tty-prompt"
require 'deck-of-cards'
require "pry"

class Baccarat < ActiveRecord::Base
    #sets class variables for the hand values for each round - look into ways to make this instance variable
    @@playerhand = []
    @@player_hand_value = nil
    @@bankerhand = []
    @@banker_hand_value = nil


    def self.deckofcards
        DeckOfCards.new.shuffle
    end

    def self.value_cards #determines the values of each card and outputs into a hash
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

    def self.player_hand_helper(hand_value) #after we check for 2 card winner
        if hand_value <= 5 
            puts "The player hand value is #{hand_value}, draw again"
            user_card3 = self.draw_card
            user_card3_value = user_card3[1][:value]
            puts "The player draws: #{user_card3[0]}"
            hand_value += user_card3_value
            puts "The player hand value is now #{hand_value}"  #want this to hit the >9
        elsif hand_value > 9 #want this 
            hand_value -= 10
            puts "Player hand value over 10, subtract 10"
            puts "Player hand value is now #{hand_value}"
        else
            puts "The player will stay, hand value is: #{hand_value}"
        end
        hand_value 
    end

    def self.hand_over_ten(hand_value) #will subtract the hand value if >10. this helper method will be called after every draw for player&dealer
        #binding.pry
        if hand_value >= 10
            hand_value -= 10
        else
            hand_value 
        end
    end

    # Round 1
    def self.player_hand #must add helper method to check if >10
        #binding.pry
        puts "The player draws two cards."
        sleep(1)
        player_card1 = self.draw_card
        @@playerhand << player_card1
        player_card2 = self.draw_card
        @@playerhand << player_card2
        player_card1_value = player_card1[1][:value]
        player_card2_value = player_card2[1][:value]

        puts "Player's Hand: #{player_card1[0]}, #{player_card2[0]}"
        sleep(1)
        @@player_hand_value = player_card1_value + player_card2_value
        @@player_hand_value = self.hand_over_ten(@@player_hand_value)
        
        puts "Player's hand value is: #{@@player_hand_value}"
        @@player_hand_value
        #self.player_hand_helper(player_hand_value)
    end



    def self.banker_hand #must add helper method to check if >10
        puts "The banker draws two cards"
        sleep(1)
        banker_card1 = self.draw_card
        @@bankerhand << banker_card1
        banker_card2 = self.draw_card
        @@bankerhand << banker_card2
        banker_card1_value = banker_card1[1][:value]
        banker_card2_value = banker_card2[1][:value]

        puts "Banker's Hand: #{banker_card1[0]}, #{banker_card2[0]}"
        sleep(1)
        @@banker_hand_value = banker_card1_value + banker_card2_value
        @@banker_hand_value = self.hand_over_ten(@@banker_hand_value)

        puts "Banker's hand value is: #{@@banker_hand_value}"
        @@banker_hand_value 
    end

    def self.winner  #if one of these true // we want this methhod to end the game, output who won the game// we then have to check our suers bet vs this outcome
        #binding.pry

        #self.player_hand
        #p @@player_hand_value
        if !@@playerhand[2]
            self.two_card_winner
        elsif @@playerhand[2]
            self.three_card_winner
        end
        #go to play again? method
    end

    private

    def two_card_winner 
        if @@player_hand_value == 8 || @@player_hand_value == 9 && (@@banker_hand_value < @@player_hand_value)
            puts "player wins"
        elsif @@banker_hand_value == 8 || @@banker_hand_value == 9  && (@@banker_hand_value > @@player_hand_value)
            puts "banker wins"
        elsif @@banker_hand_value == 8 || @@banker_hand_value == 9  && (@@banker_hand_value == @@player_hand_value)
            puts "draw"
        end
    end

    def three_card_winner

    end
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
