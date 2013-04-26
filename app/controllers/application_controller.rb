# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  include AuthenticatedSystem
  rescue_from ActionController::InvalidAuthenticityToken, :with => :rescue_from_authenticity
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def check_emails(emails)
    return false if emails.blank?
    return false if emails.gsub(',','').blank?
    emails.split(',').each do |email|
        unless email.strip =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/
          return false
        end
    end
    return true
  end

  def check_age(birthday)
   now = Time.now.utc.to_date
   now.year - birthday.year - (birthday.to_date.change(:year => now.year) > now ? 1 : 0)
  end


  def check_date(date)
    return false if date.strip.blank?
    unless date.strip =~ /\b\d{1,2}[\/-]\d{1,2}[\/-]\d{4}\b/
      return false
    end
    return true
  end

  def check_biz_login  
    if logged_in? 
      redirect_to root_path unless current_user.biz?
    else
      redirect_to biz_path  
    end
  end
  def check_normal_login  
    if logged_in? 
      redirect_to biz_dashboard_path if current_user.biz?
    else
      redirect_to root_path  
    end
  end

  def rescue_from_authenticity
    redirect_to root_path
  end
end
