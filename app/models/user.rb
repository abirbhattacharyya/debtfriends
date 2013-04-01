  require 'digest/sha1'

class User < ActiveRecord::Base
  has_one :profile, :dependent => :destroy
  has_many :user_accounts, :dependent => :destroy
  has_many :offers, :dependent => :destroy
  has_many :payments, :dependent => :destroy
  #include Authentication
  #include Authentication::ByPassword
  #include Authentication::ByCookieToken
  #before_save :prepare_password

  validates_format_of       :crypted_password, :with=> /(?!^[0-9]*$)(?!^[a-zA-Z]*$)^([a-zA-Z0-9]{8,40})$/, :message => "^Hey, Password should contain At least 8 characters and at least 1 number"
  validates_format_of       :email, :if => :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
  validates_uniqueness_of   :email, :case_sensitive => false, :if => :email, :message => "^Hey, incorrect email/password combination."



  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :email,:password,:crypted_password,:account_no



  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #

  MONTH_NAMES = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

  def password_required?
      !(crypted_password.nil?)
  end

  def valid_offer(offer_status)
    offers.is_offer_valid(offer_status)
  end

  def current_user
    @current_user ||= (login_from_session || login_from_basic_auth || login_from_cookie) unless @current_user == false
  end

  def check_pass(crypted_password)
    characters = crypted_password.size
    if characters < 8
      return false
    else
      return true  
    end
  end

  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    #u = find_by_login(login.downcase) # need to get the salt
    u = find_by_email(email.downcase)
    u && u.authenticated?(password) ? u : nil
  end

  def self.user_authenticate(email)
    return nil if email.blank?
    #u = find_by_login(login.downcase) # need to get the salt
    u = find_by_email(email.downcase)
    #u && u.authenticated?(password) ? u : nil
  end

  def biz?
    return true if self.status == "business"
    return false
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def encrypt_password(pass)
    Digest::SHA1.hexdigest([pass.downcase, salt].join)
  end

  def password_without_encryption(pass)
    self.user_pass = pass.downcase
  end

  def matching_password?(pass)  
   
    self.crypted_password == encrypt_password(pass.downcase)
  end

   def prepare_password
    unless crypted_password.blank?
      self.password = crypted_password.downcase
      self.salt = Digest::SHA1.hexdigest([Time.now, rand].join)
      self.crypted_password = encrypt_password(crypted_password.downcase)
    end
  end
  
end
