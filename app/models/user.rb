require "tty-prompt"

class User < ActiveRecord::Base
    has_many :games
    has_many :bankers, through: :games
    @@prompt = TTY::Prompt.new

    def self.signup
        username = @@prompt.ask("Choose a username:")
        password = @@prompt.mask("Choose a password:")
        self.create(username: username, password: password, balance: 10_000)
    end

    def self.login
        username = @@prompt.ask("What is your username?")
        password = @@prompt.mask("What is your password?")
        self.find_by(username: username, password: password)
    end
end