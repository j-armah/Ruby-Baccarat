class CreateGames < ActiveRecord::Migration[5.2]
  def change

    create_table :games do |t| 
      t.string :user_id
      t.string :banker_id
      t.integer :wager
      t.string :outcome
   end
  end
end
