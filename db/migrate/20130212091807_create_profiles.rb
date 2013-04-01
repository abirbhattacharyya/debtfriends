class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.integer :user_id	
      t.string  :first_name		
      t.string  :last_name
      t.string  :phone
      t.string  :ssn
      t.date    :birthdate
      t.timestamps
    end
  end

  def self.down
    drop_table :profiles
  end
end
