class AddDebtperiodToUserAccountTable < ActiveRecord::Migration
  def self.up
  	add_column :user_accounts, :debt_period, :integer
  end

  def self.down
  end
end
