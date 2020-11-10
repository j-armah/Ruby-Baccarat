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
    def run
        self.class.welcome
    end

    def self.welcome
        system('clear')
        puts @@artii.asciify("Welcome to")
        puts @@artii.asciify("Baccarat!")
        self.auth_sequence
    end

    def self.auth_sequence
        sleep(1)
        @@user = User.first
        self.display_menu
        # choices = { "Log In" => 1,
        #     "Sign Up" => 2
        # }
        # choice = @@prompt.select("Would you like to sign up or log in?", choices)
        # if choice == 1
        #     @@user = User.login
        #     if @@user
        #         self.display_menu
        #     else
        #         self.auth_sequence
        #     end
        # else
        #     @@user = User.signup
        #     if @@user
        #         self.display_menu
        #     else
        #         self.auth_sequence
        #     end
        # end
    end
    
    def self.display_menu  # Displays the options to the user! 
        system('clear')
        choices = {"Play Baccarat" => 1,
                "See my game results" => 2,
                "See my balance" => 3,
                }
        action = @@prompt.select("What would you like to do?", choices)
        case action
        when 1 
            # @banker = self.choose_banker
            #Baccarat.play_game
            self.choose_banker
        when 2
            puts "You chose to see results"
            #self.game_results
        when 3
            self.view_balance
           # puts "Your balance is currently $#{@@user.balance}"
        end
    end

    # Choose banker
    def self.choose_banker #go through banker.all and output bankers
         @@banker = @@prompt.select("What banker would you like to play against?") do |menu|
                Banker.all.select do |banker_element|
                    menu.choice banker_element.name, banker_element
                end
            end
        Baccarat.play_game
    end

    def self.game_results
        
    end
    
    def self.view_balance
        puts "Your balance is #{@@user.balance}"
        sleep(3)
        self.display_menu
    end

    def self.play_game
        #binding.pry
        # @banker = Banker.all.sample
        # @banker = Banker.find_by(name: @@banker)
        @game = Game.create(user_id: @@user.id, banker_id: @@banker.id)
        
        self.value_cards # Create deck
        
        wager = self.wager # Set wager, bet on player, banker, tie

        bet_choice = self.place_bet # What would you like to place your bet on? Banker, Player, or Tie?

        # Play round one
        puts "Round 1, Player and Banker draw two cards.\n\n"
        #sleep(3)
        self.player_round_one
        puts "\n\n"
        #sleep(3)
        self.banker_round_one
        puts "\n\n"

        #sleep(3)

        # If .winner is not nil, someone won. Else continue to round 2
        if self.winner != nil
            self.correct_bet(bet_choice)
            self.play_again
        end

        # Play round two

        puts "\nRound 2\n\n"
        #sleep(3)
        self.player_round_two
        puts "\n\n\n"
        #sleep(3)
        self.banker_round_two

        # Check if user picked the winner correctly, or lost
        self.correct_bet(bet_choice)

        self.play_again

        #binding.pry

        # Set outcome of user. Did the user bet on the right outcome? 
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
        if @@user.balance == 0
            puts "You do not have enough funds to play"
            puts "Returning to main menu"
            sleep(4)
            self.display_menu
            # Back to main menu method here - self.display_menu or something
        else
            puts "Your current balance is #{@@user.balance}"
            puts "Enter your wager"
            wager_amount = gets.chomp.to_i
            @game.update(wager: wager_amount)
            puts "You are betting #{wager_amount}"
            # Make sure wager amount does not exceed balance, helper?
            if wager_amount > @@user.balance
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

    def self.place_bet
        bet_choice = @@prompt.select("Place bet on Banker, Player, or Tie") do |menu|
            menu.choice "banker"
            menu.choice "player"
            menu.choice "tie"
        end
        bet_choice
    end

    def self.correct_bet(bet_choice) # if a user bets incorrectly, they should lose their bet. User.balance. If they win correctly, go to a payout method
        if self.winner.downcase.include?(bet_choice)
            @game.update(outcome: "win")
            self.payout(bet_choice)
        else
            @game.update(outcome: "loss")
            @@user.balance -= @game.wager
            binding.pry
        end
    end

    def self.draw_card
        self.value_cards.sample
    end

    def self.payout(bet_choice)
        if bet_choice == "player"
            @@user.balance += @game.wager
        elsif bet_choice == "banker"
            @@user.balance += @game.wager * @@banker.commission_rate
        elsif bet_choice == "tie"
            @@user.balance += @game.wager * 8
        end
    end


    def self.hand_over_ten(hand_value) #will subtract the hand value if >10. this helper method will be called after every draw for player&banker
        #binding.pry
        if hand_value >= 10
            return hand_value -= 10
        else
            hand_value 
        end
    end

    # Round 1
    def self.player_round_one #must add helper method to check if >10
        puts "Player draws two cards."
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
        puts "Banker draws two cards"
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
            puts "Player hand value is #{hand_value}, draw again"
            player_card3 = self.draw_card
            player_card3_value = player_card3[1][:value]
            @@playerhand << player_card3_value
            puts "Player draws: #{player_card3[0]}"
            hand_value += player_card3_value
            @@player_hand_value = hand_value
            @@player_hand_value = self.hand_over_ten(@@player_hand_value)  # Should automatically reduce value by 10 if goes over 10, due to helper
            puts "Player hand value is now #{@@player_hand_value}"
        else #if player hand val is 6,7
            puts "Player will stay, hand value is: #{@@player_hand_value}"  #8 or 9 Would have already gone to winner method, 6,7 banker would stay
            if @@banker_hand_value.between?(0,5)
                self.banker_round_two_draw
                #stand if banker has a 6,7
            else
                self.winner
            end
            self.winner
        end
        @@player_hand_value 
    end

    def self.banker_round_two_draw
        puts "Banker draws a card"
        banker_card3 = self.draw_card
        @@bankerhand << banker_card3
        puts "Banker drew #{banker_card3[0]}"
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

    def self.play_again
        choice = @@prompt.select("Do you want to play again?") do |menu|
            menu.choice "yes"
            menu.choice "no"
        end
        if choice == "yes"
            self.play_game
        else
            self.display_menu
        end
    end

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

    # third_draw? if banker needs to draw another card then use helper method 
    # or another method where banker draws third card

    # winner method

    # play another game method?