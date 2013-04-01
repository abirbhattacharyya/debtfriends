class CreateUserAccounts < ActiveRecord::Migration
  def self.up
    create_table :user_accounts do |t|
      t.integer :user_id		 	
      t.string  :company_name
      t.string  :phone
      t.string  :account_no
      t.float   :amount
      t.timestamps
    end
  end

  def self.down
    drop_table :user_accounts
  end
end
