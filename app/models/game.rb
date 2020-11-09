class Game < ActiveRecord::Base
    belongs_to :banker
    belongs_to :user

end