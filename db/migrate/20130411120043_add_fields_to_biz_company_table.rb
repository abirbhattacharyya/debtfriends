class AddFieldsToBizCompanyTable < ActiveRecord::Migration
  def self.up
  	add_column :biz_companies, :name, :string
  	add_column :biz_companies, :title, :string
  	add_column :biz_companies, :phone, :string
  	add_column :biz_companies, :manager, :string
  end

  def self.down
  	remove_column :biz_companies,:name
  	remove_column :biz_companies,:title
  	remove_column :biz_companies,:phone
  	remove_column :biz_companies,:manager
  end
end
