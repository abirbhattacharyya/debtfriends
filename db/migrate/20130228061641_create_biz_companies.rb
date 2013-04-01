class CreateBizCompanies < ActiveRecord::Migration
  def self.up
    create_table :biz_companies do |t|
      t.integer :user_id
      t.string  :company_name	
      t.timestamps
    end
  end

  def self.down
    drop_table :biz_companies
  end
end
