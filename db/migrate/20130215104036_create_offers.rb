class CreateOffers < ActiveRecord::Migration
  def self.up
    create_table :offers do |t|
      t.integer :user_id
      t.integer :user_account_id
      t.float   :amount	
      t.string  :status
      t.timestamps
    end
  end

  def self.down
    drop_table :offers
  end
end
