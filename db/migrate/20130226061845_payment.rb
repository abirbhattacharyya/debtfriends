class Payment < ActiveRecord::Migration
  def self.up
  	 create_table :payments do |t|
      t.integer :offer_id
      t.float :amount
      t.string :status
      t.date :payment_date
      t.string :transaction_id

      t.timestamps
    end
  end
  
  def self.down
   drop_table :payments
  end
end
