class AddPasswordToUserTable < ActiveRecord::Migration
  def self.up
  	add_column :users, :password, :string
  end

  def self.down
  end
end
