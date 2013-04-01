class AddResponseFieldToOfferTable < ActiveRecord::Migration
  def self.up
  	add_column :offers,:response,:string
  end

  def self.down
  	remove_column :offers,:response
  end
end
