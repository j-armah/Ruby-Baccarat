require "tty-prompt"
require 'deck-of-cards'
require "pry"

class Baccarat
    #sets class variables for the hand values for git each round - look into ways to make this instance variable
    # @@playerhand = []
    @@player_hand_value = nil
    # @bankerhand = []
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
        #@@user = User.first
        choices = { "Log In" => 1,
            "Sign Up" => 2
        }
        choice = @@prompt.select("Would you like to sign up or log in?", choices)
        if choice == 1
            @@user = User.login
            if @@user
                self.display_menu
            else
                puts "Invalid username or password. Please try again or sign up."
                sleep(2)
                system('clear')
                self.auth_sequence
            end
        else
            @@user = User.signup
            if @@user
                self.display_menu
            else
                self.auth_sequence
            end
        end
        self.display_menu
    end
    
    def self.display_menu  # Displays the options to the user! 
        system('clear')
        choices = {"Play Baccarat" => 1,
                "See my game results" => 2,
                "See my balance" => 3,
                "Deposit money" => 4,
                "Delete user" => 5,
                "Exit app" => 6
                }
        action = @@prompt.select("What would you like to do?", choices)
        case action
        when 1 
            self.choose_banker
        when 2
            puts "You chose to see results"
            self.game_results
        when 3
            puts "Your balance is #{@@user.balance}"
            sleep(3)
            self.display_menu
        when 4
            self.deposit_money
        when 5
            self.delete_user
        when 6
            puts "Good bye"
            sleep(2)
            exit
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
        # binding.pry
        puts "Out of #{@@user.games.count} games, you have won #{@@user.games.where(outcome: 'win').count}. 
        Your winning percentage is #{100*@@user.games.where(outcome: 'win').count/@@user.games.count.to_f.round(2)}%."
        sleep(3)
        self.display_menu
    end
    

    def self.play_game

        @game = Game.create(user_id: @@user.id, banker_id: @@banker.id)
        @playerhand = []
        @bankerhand = []
        self.value_cards # Create deck
        # binding.pry

        self.wager # Set wager, bet on player, banker, tie
        binding.pry
        bet_choice = self.place_bet # What would you like to place your bet on? Banker, Player, or Tie?

        # Play round one
        puts "Round 1, Player and Banker draw two cards.\n\n"
        sleep(1)
        self.player_round_one
        puts "\n\n"
        sleep(1)
        self.banker_round_one
        puts "\n\n"
        sleep(1)

        # binding.pry
        if !self.two_card_winner.include?("No") 
            sleep(1)   #checking if there is initial win, if yes we will restart the game
            puts self.two_card_winner
            sleep(1)
            self.correct_bet(bet_choice)    # Else, head to round 2
            sleep(0.5)
            self.play_again
        end

        # Play round two
        puts "\nRound 2\n\n"
        sleep(1)
        self.player_round_two
        puts "\n\n\n"
        sleep(1)
        self.banker_round_two
        sleep(1)
        puts "\n\n"
        puts self.three_card_winner
        puts "\n\n"
        sleep(1)
        self.correct_bet(bet_choice) # # Check if user picked the winner correctly, or lost
        self.play_again
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

    #WAGER METHOD 
    def self.wager
        if @@user.balance == 0
            puts "You do not have enough funds to play"
            puts "Returning to main menu"
            sleep(4)
            self.display_menu # Back to main menu
        else
            # binding.pry
            puts "Your current balance is #{@@user.balance}"
            puts "Enter your wager"
            wager_amount = gets.chomp.to_i
            self.validate_wager_amt(wager_amount)
             binding.pry
            @game.update(wager: wager_amount)
             binding.pry
            puts "You are betting #{wager_amount}"
             #for some reason, after it gets the correct wager, it runs an additional time for the initial input
        end
    end

    def self.validate_wager_amt(wager_amount)
        # binding.pry
        if wager_amount > @@user.balance
            puts "You do not have enough money to wager #{wager_amount}."
            self.wager
        elsif wager_amount <= 0
            puts "You must place a bet above 0"
            sleep(2)
            self.wager
        # else
        #     puts "Your wager is #{wager_amount}"
        #     wager_amount
        end
        binding.pry
    end

    def self.place_bet
        bet_choice = @@prompt.select("Place bet on Banker, Player, or Tie") do |menu|
            menu.choice "Banker"
            menu.choice "Player"
            menu.choice "Tie"
        end
        bet_choice
    end

    def self.correct_bet(bet_choice) # if a user bets incorrectly, they should lose their bet. User.balance. If they win correctly, go to a payout method
        #may be double printing the wins here
        #binding.pry
        if self.three_card_winner.include?(bet_choice) || self.two_card_winner.include?(bet_choice)
            @game.update(outcome: "win")
            self.payout(bet_choice)
        # elsif self.two_card_winner.include?(bet_choice)
        #     @game.update(outcome: "win")
        #     self.payout(bet_choice)
        else
            @game.update(outcome: "loss")
            @@user.balance -= @game.wager
            puts "Your bet lost, your balance was reduced by #{@game.wager}"
            # binding.pry
        end
        binding.pry
    end

    def self.draw_card
        self.value_cards.sample
    end

    def self.payout(bet_choice)
        if bet_choice == "Player"
            @@user.balance += @game.wager
            puts "You won #{@game.wager.round(2)}"
        elsif bet_choice == "Banker"
            @@user.balance += @game.wager * @@banker.commission_rate
            puts "You won #{(@game.wager * @@banker.commission_rate).round(2)}"
        elsif bet_choice == "Tie"
            @@user.balance += @game.wager * 8
            puts "You won #{(@game.wager * 8).round(2)}!"
        end
    end

    def self.hand_over_ten(hand_value) #will subtract the hand value if >10
        if hand_value >= 10
            return hand_value -= 10
        else
            hand_value 
        end
    end

    # Round 1
    def self.player_round_one 
        puts "Player draws two cards."
        sleep(1)

        player_card1 = self.draw_card
        @playerhand << player_card1
        player_card2 = self.draw_card
        @playerhand << player_card2
        player_card1_value = player_card1[1][:value]
        player_card2_value = player_card2[1][:value]

        puts "Player's Hand: #{player_card1[0]}, #{player_card2[0]}"
        sleep(1)
        @@player_hand_value = self.hand_over_ten(player_card1_value + player_card2_value)
        puts "Player's hand value is: #{@@player_hand_value}"
        @@player_hand_value
    end


    def self.banker_round_one 
    
        puts "Banker draws two cards"
        sleep(1)
        banker_card1 = self.draw_card
        @bankerhand << banker_card1
        banker_card2 = self.draw_card
        @bankerhand << banker_card2
        banker_card1_value = banker_card1[1][:value]
        banker_card2_value = banker_card2[1][:value]

        puts "Banker's Hand: #{banker_card1[0]}, #{banker_card2[0]}"
        sleep(1)
        @@banker_hand_value = self.hand_over_ten(banker_card1_value + banker_card2_value)

        puts "Banker's hand value is: #{@@banker_hand_value}"
        @@banker_hand_value 
    end

    ##### AFTER ROUND 1 CHECK FOR WINNER. IF NO WINNER PROCEED TO ROUND 2 ####
    # if self.winner has a winner for two card winner go to self.play_again? method
    # else we go to round 2

    ### WE HAVE PLAYED ROUND ONE, IF THERE IS NO WINNER WE GO HERE


    def self.banker_round_two 
        #If the Player stands pat (or draws no new cards), the Banker draws with a hand total of 0-5 
        #and stays pat with a hand total of 6 or 7. 
        #binding.pry
        if !@@playerhand[2]   
            #binding.pry
            if @@banker_hand_value.between?(6,7)
                puts "Banker stays"
            elsif @@banker_hand_value.between?(0,5)
                self.banker_round_two_draw
            end
        elsif @playerhand[2] == 0 || @playerhand[2] == 9 || @playerhand[2] == 1
            if @@banker_hand_value.between?(4,7)
                puts "Banker stays" 
            else 
                self.banker_round_two_draw 
            end
        elsif @playerhand[2] == 2 || @playerhand[2] == 3
            if @@banker_hand_value.between?(5,7)
                puts "Banker stays" 
            else 
                self.banker_round_two_draw 
            end
        elsif @playerhand[2] == 4 || @playerhand[2] == 5
            if @@banker_hand_value.between?(6,7)
                puts "Banker stays"  
            else 
                self.banker_round_two_draw  
            end
        elsif @playerhand[2] == 6 || @playerhand[2] == 7
            if @@banker_hand_value == 7
                puts "Banker stays"  
            else 
                self.banker_round_two_draw 
            end
        elsif @playerhand[2] == 8
            if @@banker_hand_value.between?(3,7)
                puts "Banker stays"  
            else 
                self.banker_round_two_draw 
            end
        end
        self.three_card_winner #go to check winner
    end 

    def self.player_round_two # Why user&player?
        if @@player_hand_value <= 5 
            puts "Player's hand value is #{@@player_hand_value}, draw again"
            sleep(1)
            player_card3 = self.draw_card
            player_card3_value = player_card3[1][:value]
            @playerhand << player_card3_value
            puts "Player draws a #{player_card3[0]}"
            sleep(1)
            @@player_hand_value += player_card3_value
            
            @@player_hand_value = self.hand_over_ten(@@player_hand_value)  #if hand>=10, -=10
            puts "Player's hand value is now #{@@player_hand_value}"
        else #if player hand val is 6,7
            puts "Player will stay, hand value is #{@@player_hand_value}"  #8 or 9 Would have already gone to winner method, 6,7 banker would stay
        end
        @@player_hand_value 
    end

    def self.banker_round_two_draw
        puts "Banker draws a card"
        sleep(0.5)
        banker_card3 = self.draw_card
        @bankerhand << banker_card3
        puts "Banker drew #{banker_card3[0]}"
        sleep(1)
        @@banker_hand_value += banker_card3[1][:value]
        @@banker_hand_value = self.hand_over_ten(@@banker_hand_value)
        puts "Banker hand value is now #{@@banker_hand_value}"
        sleep(1)
    end

    # def self.winner  #if one of these true // we want this methhod to end the game, output who won the game//
    #     # winner method getting passed through twice for some reason
    #     if !@playerhand[2] && !@bankerhand[2]
    #         self.two_card_winner
    #     else
    #         self.three_card_winner
    #     end
    #     #binding.pry
    # end

    def self.play_again
        choice = @@prompt.select("Do you want to play again?") do |menu|
            menu.choice "yes"
            menu.choice "no"
        end
        if @@user.balance <= 0
            puts "You lost all your money... Returning to main menu."
            sleep(4)
            self.display_menu
        else
            if choice == "yes"
                self.play_game
            else
                self.display_menu
            end
        end
    end

    private

    def self.deposit_money
        puts "How much would you like to deposit?"
        @@user.balance += gets.chomp.to_f
        self.display_menu
    end

    def self.two_card_winner 
        if (@@player_hand_value == 8 || @@player_hand_value == 9) && (@@banker_hand_value < @@player_hand_value)
            "Player wins!"
        elsif (@@banker_hand_value == 8 || @@banker_hand_value == 9)  && (@@banker_hand_value > @@player_hand_value)
            "Banker wins!"
        elsif (@@banker_hand_value == 8 || @@banker_hand_value == 9)  && (@@banker_hand_value == @@player_hand_value)
            "It's a Tie"
        else
            "No two card win"
        end
    end

    def self.three_card_winner
        if @@player_hand_value > @@banker_hand_value
            "Player wins!"
        elsif @@player_hand_value < @@banker_hand_value
            "Banker wins!"
        else
            "It's a Tie"
        end
    end
    
end

# SCHEMA REMINDER. player_hand and banker_hand, how are we storing this?
# Player third card doesn't seem needed? Since we have class variables we can just check [2] index
# Outcome needs to be set in winner method(s)

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
