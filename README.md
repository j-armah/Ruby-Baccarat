# Baccarat!
========================

Baccarat is a CLI card game based in Ruby. The user can play games of and bet on who will win each game. The goal of Baccarat is to bet on an outcome between the banker/dealer and a figurative "player". You may bet on either the banker hand, player hand, or you may bet on a tie. 

The user can create a user account, login with their account, and delete their account. Every user is created with a default amount of money. The user can view their current balance, their win percentage and amount of games, and the banker they played with the most. The user can also delete thier past game results and start fresh. If the user loses all their money, they can cheat and deposit more money!

---
# Install Instructions
========================
To install:
Clone this repo down to your local machine and run bundle install.

Run rake db:migrate to initialize the databases

Run rake db:seed to initialize default bankers

You're ready to play!

# Acknowledgements
=========================
Gems:
ArtII
https://github.com/miketierney/artii

Deck-Of-Card
https://github.com/Havenwood/deck-of-cards

TTY-Prompt
https://github.com/piotrmurach/tty-prompt