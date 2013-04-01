class Payment < ActiveRecord::Base
  belongs_to :offer
  belongs_to :user

 
  PAYMENT_STATUS = {
    :pending => 0,
    :success => 1,
    :reject =>2
  }

end