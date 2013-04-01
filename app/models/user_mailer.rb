class UserMailer < ActionMailer::Base
 def forgot_password(user,sent_on = Time.now)
    subject    'Your forgotten password for Debt_Friends'
    recipients  user.email
    from       'support@debtfriends.com'
    body       :user => user
    content_type 'text/html'
  end  

  def update_notification_from_biz(user,sent_on = Time.now)
  	subject    'You have an update on Debtfriends'
    recipients  user.email #consumer's email
    from       'support@debtfriends.com'
    body       :user => user
    @user = user
    content_type 'text/html'
  end

end
