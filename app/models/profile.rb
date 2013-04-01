class Profile < ActiveRecord::Base

  belongs_to :user	  	
  validates_presence_of  :first_name,:message=>"Please enter first name"
  validates_presence_of  :last_name,:message=>"Please enter last name"
  validates_presence_of  :phone,:message=>"Please enter phone no"
  validates_presence_of  :ssn,:message=>"Please enter ssn"
  validates_format_of    :ssn, :with => /^[0-9]{4}$/, \
    :message => "4 digits, please."
  validates_presence_of  :birthdate,:message=>"Please enter birthdate"
  
end
