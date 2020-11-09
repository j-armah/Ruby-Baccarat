class CreateBankers < ActiveRecord::Migration[5.2]
  def change
    create_table :bankers do |t| 
      t.string :name
      t.float :commission_rate
   end
  end
end
