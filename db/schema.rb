# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130411120043) do

  create_table "biz_companies", :force => true do |t|
    t.integer  "user_id"
    t.string   "company_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "title"
    t.string   "phone"
    t.string   "manager"
  end

  create_table "offers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "user_account_id"
    t.float    "amount"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "response"
  end

  create_table "payments", :force => true do |t|
    t.integer  "offer_id"
    t.float    "amount"
    t.string   "status"
    t.date     "payment_date"
    t.string   "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "ssn"
    t.date     "birthdate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_accounts", :force => true do |t|
    t.integer  "user_id"
    t.string   "company_name"
    t.string   "phone"
    t.string   "account_no"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "debt_period"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "password"
    t.string   "status"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
