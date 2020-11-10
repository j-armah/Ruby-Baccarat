require "tty-prompt"
require 'deck-of-cards'
require "pry"

class Baccarat
    #sets class variables for the hand values for each round - look into ways to make this instance variable
    @@playerhand = []
    @@player_hand_value = nil
    @@bankerhand = []
    @@banker_hand_value = nil
    @@prompt = TTY::Prompt.new
    @@artii = Artii::Base.new :font => 'slant'
    @@user = nil

    ####### CLI FRAMEWORK/SKELETON
    # def welcome
    #     system('clear')
    #     puts @@artii.asciify("Welcome to")
    #     puts @@artii.asciify("Baccarat ( Lite )!")
    #     self.auth_sequence
    # end

    # def auth_sequence
    #     sleep(1.5)
    #     @@user = User.first
    #     self.display_menu
    # end
    
    # def display_menu
    #     # Displays the options to the user!
    #     system('clear')
    #     choices = { "Play Baccarat" => 1,
    #             "Set difficulty" => 2, 
    #             "See my game results" => 3,
    #             "See leaderboard" => 4,
    #             "Select from all categories" => 5
    #         }
    #     action = @@prompt.select("What would you like to do?", choices)
    #     case action
    #     when 1 
    #         random_cat = Category.all.sample # gets random category from those seeded
    #         api_data = self.get_category_data(random_cat) # uses helper method to get clues from API
    #         self.play_game(random_cat.id, api_data) # plays the game!
    #     when 2
    #         puts "You chose to search"
    #     when 3
    #         puts "You chose to see results"
    #     when 4
    #         puts "You chose to see your game results"
    #     when 5
    #         chosen_category = self.choose_category # uses helper method to display and get category choice
    #         api_data = self.get_category_data(chosen_category) # uses helper method to get clues from API
    #         self.play_game(chosen_category.id, api_data) # plays the game!
    #     end
    # end

    def play_game
        # Create deck
        Baccarat.value_cards

        # Set wager, bet on player, banker, tie

        # Play round one
        puts "Round 1, Player and Dealer draw two cards.\n\n"
        sleep(3)
        Baccarat.player_round_one
        puts "\n\n"
        sleep(3)
        Baccarat.banker_round_one
        puts "\n\n"

        sleep(3)

        # If .winner is not nil, someone won. Else continue to round 2
        if Baccarat.winner != nil
            return Baccarat.winner # Go to play_again?
        end

        # Play round two

        puts "\nRound 2\n\n"
        sleep(3)
        Baccarat.player_round_two
        puts "\n\n\n"
        sleep(3)
        Baccarat.banker_round_two

        # Set outcome of user. Did the user bet one the right outcome? 
        # Banker win? Player win? Tie? 

        # Would you like to play again?
        # Return to menu?

    end

    # Deck set
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

    # WAGER METHOD SOMEWHERE, needs to check balance of user
    # How do I see @user.balance...? No users so no way to test right now?
    def self.wager
        if @user.balance == 0
            puts "You do not have enough funds to play"
            # Back to main menu method here - self.display_menu or something
        else
            puts "Your current balance is #{@user.balance}"
            puts "Enter your wager"
            wager_amount = gets.chomp.to_i
            @game.update(wager: wager_amount)
            # Make sure wager amount does not exceed balance, helper?
            if wager_amount > @user.balance
                puts "You do not have enough money to wager #{wager_amount}. Your balance is #{@@user.balance}"
                self.wager
            elsif wager_amount <= 0
                "You must place a bet above 0"
                self.wager
            else
                "Puts your wager is #{wager_amount}"
            end
        end
    end


    def self.draw_card
        self.value_cards.sample
    end



    def self.hand_over_ten(hand_value) #will subtract the hand value if >10. this helper method will be called after every draw for player&dealer
        #binding.pry
        if hand_value >= 10
            return hand_value -= 10
        else
            hand_value 
        end
    end

    # Round 1
    def self.player_round_one #must add helper method to check if >10
        puts "The player draws two cards."
        #sleep(1)
        player_card1 = self.draw_card #look into combining lines here
        @@playerhand << player_card1
        player_card2 = self.draw_card
        @@playerhand << player_card2
        player_card1_value = player_card1[1][:value]
        player_card2_value = player_card2[1][:value]

        puts "Player's Hand: #{player_card1[0]}, #{player_card2[0]}"
        #sleep(1)
        @@player_hand_value = player_card1_value + player_card2_value
        @@player_hand_value = self.hand_over_ten(@@player_hand_value)

        puts "Player's hand value is: #{@@player_hand_value}"
        @@player_hand_value
        #self.player_hand_helper(player_hand_value)
        # binding.pry

    end


    def self.banker_round_one #must add helper method to check if >10
        puts "The banker draws two cards"
        #sleep(1)
        banker_card1 = self.draw_card
        @@bankerhand << banker_card1
        banker_card2 = self.draw_card
        @@bankerhand << banker_card2
        banker_card1_value = banker_card1[1][:value]
        banker_card2_value = banker_card2[1][:value]

        puts "Banker's Hand: #{banker_card1[0]}, #{banker_card2[0]}"
        #sleep(1)
        @@banker_hand_value = banker_card1_value + banker_card2_value
        @@banker_hand_value = self.hand_over_ten(@@banker_hand_value)

        puts "Banker's hand value is: #{@@banker_hand_value}"
        @@banker_hand_value 
        # binding.pry

    end

    ##### AFTER ROUND 1 CHECK FOR WINNER. IF NO WINNER PROCEED TO ROUND 2 ####
    # if self.winner has a winner for two card winner go to self.play_again? method
    # else we go to round 2

    ### WE HAVE PLAYED ROUND ONE, IF THERE IS NO WINNER WE GO HERE
    # I put everything in helper, so there's only one line here? Do we need a helper?
    def self.player_round_two
        self.player_round_two_helper(@@player_hand_value)

    end

    def self.banker_round_two #this is only called after player round 2
        if @@playerhand[2] == 0 || @@playerhand[2] == 9 || @@playerhand[2] == 1
            if @@banker_hand_value.between?(4,7)
                puts "Banker stays" #go to winner? 
            else 
                puts "Banker draws" 
                self.banker_round_two_draw #make banker draw 3rd, then go to winner?
            end
        elsif @@playerhand[2] == 2 || @@playerhand[2] == 3
            if @@banker_hand_value.between?(5,7)
                puts "Banker stays" #go to winner? 
            else 
                puts "Banker draws" 
                self.banker_round_two_draw #make banker draw 3rd, then go to winner?
            end
        elsif @@playerhand[2] == 4 || @@playerhand[2] == 5
            if @@banker_hand_value.between?(6,7)
                puts "Banker stays" #go to winner? 
            else 
                puts "Banker draws" 
                self.banker_round_two_draw  #make banker draw 3rd, then go to winner?
            end
        elsif @@playerhand[2] == 6 || @@playerhand[2] == 7
            if @@banker_hand_value == 7
                puts "Banker stays" #go to winner? 
            else 
                puts "Banker draws" 
                self.banker_round_two_draw #make banker draw 3rd, then go to winner?
            end
        elsif @@playerhand[2] == 8
            if @@banker_hand_value.between?(3,7)
                puts "Banker stays" #go to winner? 
            else 
                puts "Banker draws" 
                self.banker_round_two_draw #make banker draw 3rd, then go to winner?
            end
        end
        self.winner #go to check winner
    end 

    # Helper for round two player draw.. can rename w/o "helper" 
    def self.player_round_two_helper(hand_value) #after we check for 2 card winner // Why user&player?
        if hand_value <= 5 
            puts "The player hand value is #{hand_value}, draw again"
            player_card3 = self.draw_card
            player_card3_value = player_card3[1][:value]
            @@playerhand << player_card3_value
            puts "The player draws: #{player_card3[0]}"
            hand_value += player_card3_value
            @@player_hand_value = hand_value
            @@player_hand_value = self.hand_over_ten(@@player_hand_value)  # Should automatically reduce value by 10 if goes over 10, due to helper
            puts "The player hand value is now #{@@player_hand_value}"
        else #if player hand val is 6,7
            puts "The player will stay, hand value is: #{@@player_hand_value}"  #8 or 9 Would have already gone to winner method, 6,7 banker would stay
            if @@banker_hand_value.between?(0,5)
                self.banker_round_two_draw
                #stand if banker has a 6,7
            end
            self.winner
        end
        @@player_hand_value 
    end

    def self.banker_round_two_draw
        puts "The banker draws a card"
        banker_card3 = self.draw_card
        @@bankerhand << banker_card3
        puts "The banker drew #{banker_card3[0]}"
        @@banker_hand_value += banker_card3[1][:value]
        @@banker_hand_value = self.hand_over_ten(@@banker_hand_value)
        puts "Banker hand value is now #{@@banker_hand_value}"
    end

    ### POST ROUND 2 WINNER CHECK, three card winner check ###
    ### PLAY_AGAIN? Method ###

    ### WINNER METHOD NEEDS TO SET THE OUTCOME ###
    # Outcome = Did you win/lose/tie? store as string.


    def self.winner  #if one of these true // we want this methhod to end the game, output who won the game//
        if !@@playerhand[2] && !@@bankerhand[2]
            self.two_card_winner
        else
            self.three_card_winner
        end
        #go to play again? method
    end

    ### AFTER WINNER, DO YOU WANT TO PLAY AGAIN METHOD ###

    private

    def self.two_card_winner 
        if (@@player_hand_value == 8 || @@player_hand_value == 9) && (@@banker_hand_value < @@player_hand_value)
            p "Player wins!"
        elsif (@@banker_hand_value == 8 || @@banker_hand_value == 9)  && (@@banker_hand_value > @@player_hand_value)
            p "Banker wins"
        elsif (@@banker_hand_value == 8 || @@banker_hand_value == 9)  && (@@banker_hand_value == @@player_hand_value)
            p "Tie"
        end
    end

    def self.three_card_winner
        if @@player_hand_value > @@banker_hand_value
            p "Player wins!"
        elsif @@player_hand_value < @@banker_hand_value
            p "Banker wins!"
        else
            p "Tie"
        end
    end
end

# SCHEMA REMINDER. player_hand and banker_hand, how are we storing this?
# Player third card doesn't seem needed? Since we have class variables we can just check [2] index
# Outcome needs to be set in winner method(s)
# t.string "user_id"
# t.string "banker_id"
# t.integer "wager"
# t.integer "player_hand"
# t.integer "banker_hand"
# t.integer "player_third_card"
# t.string "outcome"



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
