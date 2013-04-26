class Offer < ActiveRecord::Base
	belongs_to :user_account
  has_one :payment, :dependent => :destroy
	#belongs_to :user

  OFFER_STATUS = {
    :pending => 0,
    :active => 1,
    :fail =>2
  }


	def self.is_offer_valid(is_valid_offer)
	  last
     status = is_valid_offer
     case status
     when "yes"
       status = OFFER_STATUS[:active]
     when "no"
       status = OFFER_STATUS[:fail]
     else
       puts "Something wrong" 
     end  
	end

  def self.pending_offer
    Offer.all(:conditions => ["user_id = ? && response IS NULL", current_user.id])
  end

  def self.consumer_pending_offers(current_user)
    Offer.all(:conditions => ["user_id = ? && response = ?", current_user.id,"counter"])
  end

  def self.offer_of_current_user_account(current_user,user_account_id,response)
    if response == "IS NULL"
      Offer.all(:conditions => ["user_id = ? && user_account_id =? && response IS NULL", current_user,user_account_id])
    else
      Offer.all(:conditions => ["user_id = ? && user_account_id =?", current_user,user_account_id])
    end
  end

  def self.offers_not_in_pending_state(current_user,user_account_id)
    Offer.all(:conditions=>["user_id =? && user_account_id = ? && status not in (?)",current_user,user_account_id,Offer::OFFER_STATUS[:pending]])
  end

  #def self.all_offer_of_current_user_account(current_user,user_account_id)
  #  Offer.all(:conditions => ["user_id = ? && user_account_id =? ", current_user,user_account_id])
  #end


  def self.counter_offer_of_current_user_account(current_user,user_account_id)
    Offer.all(:conditions => ["user_id = ? && user_account_id = ? && response = 'counter'", current_user,user_account_id])
  end

  def status_update(response)
    update_attributes(:status => response)
  end

  def by_consumer?
    return true if self.response == "counter"
    return false
  end
  def by_biz?
    return true if self.response.nil?
    return false
  end
end
