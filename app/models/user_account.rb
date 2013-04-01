class UserAccount < ActiveRecord::Base
  belongs_to :user
  has_many :offers, :dependent => :destroy
  
  validates_presence_of  :company_name
  validates_presence_of  :phone
  validates_presence_of  :account_no
  validates_presence_of  :amount
  
  attr_accessor :term_condition
  validates_acceptance_of :term_condition,:allow_nil=>true	

   PAY_DEBT_PERIOD = {
    "0-12 Months ago" => 0,
    "1-5 Years ago" => 1,
    "5+ Years ago" => 2
  }

  def self.pay_debt_order
     PAY_DEBT_PERIOD.sort_by {|_key, value| value}
     
  end

  def self.user_accounts
    UserAccount.all(:conditions => ["user_id = ?", current_user.id])
  end

  def self.current_user_account(account_id)
    UserAccount.first(:conditions => ["id = ?",account_id])
  end

  def self.options_for_period

  end

end
