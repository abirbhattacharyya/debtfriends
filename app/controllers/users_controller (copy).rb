class UsersController < ApplicationController
  include ActiveMerchant::Billing::Integrations
  # Be sure to include AuthenticationSystem in Application Controller instead
  before_filter :check_normal_login,:only=>[:show_account,:negotiate,:pending_offers,:consumer_profile,:create_consumer_profile,:user_account,:create_user_account,:create_offer,:notify,:success_return,:cancel_return]
  before_filter :check_biz_login,:only=>[:biz_dashboard,:biz_show_account,:biz_negotiate,:biz_pending_offer,:biz_accepted_offer,:biz_my_agreements,:biz_statistics]
  skip_before_filter :verify_authenticity_token, :only => [:notify,:success_return,:cancel_return]

  include AuthenticatedSystem
  
  # render new.rhtml
  def new
    @user = User.new
  end

  def create
    logout_keeping_session!
    @user = User.new(params[:user])

    success = @user && @user.save
    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  def consumer_profile
    begin
    @profile = current_user.profile
    @birthdate = @profile.birthdate.strftime('%m/%d/%Y')
    age = check_age(@profile.birthdate)
    if age > 98 || age < 18 
      flash[:error] = "Please enter a valid date"
      render :action => "consumer_profile"
      return
    end
  rescue ArgumentError => e
    flash[:error] = "Please enter a valid date"
    render :action => "consumer_profile"
    return
  end  
  end


  def create_consumer_profile
    @profile = Profile.find_or_initialize_by_user_id(current_user.id) 
#   @birthdate = (@profile.birthdate.nil?) ? "" : @profile.birthdate.strftime('%m/%d/%Y')
    @birthdate = @profile.birthdate.strftime('%m/%d/%Y') unless (@profile.birthdate.blank?)

    if request.post?
      if check_date(params[:profile][:birthdate])
		    @profile.attributes = params[:profile]
		    @profile.birthdate = Date.strptime(params[:profile][:birthdate], '%m/%d/%Y')
	    else
        @birthdate = params[:profile][:birthdate]
        flash[:error] = "Please enter a valid date"
        render :action => "consumer_profile"
        return
      end
    end

    if !params[:user_profile_id].blank?
      if @profile.save
          flash[:notice] = "Profile Updated"
          @term_condition = true
          redirect_to profile_path
        else
         if @profile.errors.first[0] == "ssn"
           flash[:error] = "Plese enter 4 digit SSN "
           render 'consumer_profile'
         else  
           flash[:error] = "Please enter your profile information"
           render 'consumer_profile'
         end   
        end
    else  
      #@profile = Profile.new(params[:profile])
      @profile.user_id = current_user.id
      if @profile.save     
        flash[:notice] = "Profile Updated"
        @term_condition = true
        redirect_to user_account_path()
      else
         if @profile.errors.first[0] == "ssn"
           flash[:error] = "Plese enter 4 digit SSN "
           render 'consumer_profile'
         else  
           #flash[:error] = "Please enter your profile information"
           render 'consumer_profile'
         end   
      end
    end
    rescue ArgumentError => e
    flash[:error] = "Please enter a valid date"
    render :action => "consumer_profile"
    return
  end

  def biz_dashboard
    if request.xhr?
      @companies = BizCompany.find(:all,:conditions => ['company_name LIKE ?', params[:term]+"%"],:limit => 10, :group => 'company_name', :order => 'company_name ASC')
      render :json => @companies.map(&:company_name)
    elsif request.post?
      @biz_company = BizCompany.new(params[:biz_company])
      unless @biz_company.valid?    
        flash[:error] = "Please enter details of the company you are collecting for"
        render :template => "users/biz_company"
      else
        @biz_company = BizCompany.create(:user_id => current_user.id,:company_name=>params[:biz_company][:company_name])
        @company_users = UserAccount.all(:conditions=>["company_name = ?",params[:biz_company][:company_name]])
      end
    else
      @biz_company = BizCompany.new
      render :template => "users/biz_company" 
    end
  end

  def biz_my_agreements
    @user_com  =  BizCompany.find_by_user_id(current_user.id)
    @company_users = UserAccount.all(:conditions=>["company_name = ?",@user_com.company_name])
    @active_offers = Offer.all(:conditions => ["user_id = ? && response IS NULL && status = 1", current_user.id])
  end

  def biz_statistics

    @total_debt = 0
    @chart_data11 = []
    @colors = []
    @total_settled = 0
    @user_com  =  BizCompany.find_by_user_id(current_user.id)
    @company_users = UserAccount.all(:conditions=>["company_name = ?",@user_com.company_name])
    @all_user_accounts = UserAccount.all
    @page_title="Here are all the potential recovery monies we are referring to you"
    
    unless @company_users.blank?
      @company_users.each do |company_user|
        @total_debt = @total_debt + company_user.amount
        @offers = Offer.last(:conditions=>["user_id = ? && user_account_id = ? && status = 1",company_user.user_id,company_user.id])
        @total_settled += 1 if @offers
      end  
      @average_settlement_percentage = (@total_settled.to_f * 100) / @all_user_accounts.size
      @total_dettled_in_percentage = (@total_settled.to_f * 100) / @company_users.size
     else
      @total_debt = 0
      @total_dettled_in_percentage = 0.00
      @average_settlement_percentage = 0.00
    end
  end

  def delete_debt
    @user_account = UserAccount.find(params[:id])
    @user_account.destroy
    flash[:notice] = "We deleted this debt. Please reenter, if you want"
    redirect_to root_path
  end


  def user_account
    @term_condition = true
    @user_account = UserAccount.new
  end

  def biz_pending_offer
    @user_com  =  BizCompany.find_by_user_id(current_user.id)
    @company_users = UserAccount.all(:conditions=>["company_name = ?",@user_com.company_name])
  end 

  def biz_accepted_offers
    @user_com  =  BizCompany.find_by_user_id(current_user.id)
    @company_users = UserAccount.all(:conditions=>["company_name = ?",@user_com.company_name])
  end

  def pending_offers
    @pending_offers = []
    @offers = current_user.offers
    @user_accounts = @offers.map(&:user_account_id).uniq
    @user_accounts.each do |pending_user_account|
	  status_sum = @offers.map{|o| o.status.to_i if(o.user_account_id == pending_user_account)}.compact.inject(:+)
	  #render :text => status_sum.inspect and return false
      @counter_offers = @offers.find_all{|o| o if(o.status.eql?("0") and o.user_account_id == pending_user_account and o.response.eql?("counter"))}
      if status_sum == 0 and @counter_offers.count > 0 
        @pending_offers << @offers.find_all{|po| po.user_account_id == pending_user_account}.last
      end 
    end
	if @pending_offers.empty?
		flash[:notice] = "Nothing Pending, please add debts or start offers."
		redirect_to "/"
	end
  end  
  
  def biz_show_account
    begin
    @current_account = UserAccount.find(params[:id])
    session[:account_id] = params[:id]

    @account_user = @current_account.user
    @offer = Offer.offer_of_current_user_account(@account_user.id,@current_account.id,"")
    @latest_offer = @offer.last

    @consumer_offer = Offer.all(:conditions => ["user_id = ? && user_account_id = ? && response = 'counter'",@account_user.id,@current_account.id])
    @consumer_offer = @consumer_offer.last

    @consumer_first_offer = Offer.first(:conditions=>["user_id= ? && user_account_id = ? && response = 'counter'",@account_user.id,@current_account.id])

    @all_merchant_offers = Offer.offer_of_current_user_account(@account_user.id,@current_account.id,"IS NULL")

    @system_offer = Offer.offer_of_current_user_account(@account_user.id,@current_account.id,"IS NULL").first


    case @latest_offer.status.to_i
    when 1
      @payment = @latest_offer.payment || Payment.create(:offer_id => @latest_offer.id,:amount=>@latest_offer.amount,:status=>Payment::PAYMENT_STATUS[:pending],:transaction_id => "",:user_id=>current_user.id)
      if @payment && @payment.status == 1 && !@payment.transaction_id.nil?
      else
          render :template => "/users/biz_settlement"   
        #render :template => "/users/counter_offer"   
      end  
    when 2
      render :template => "/users/reject_offer"  
    else
      if @latest_offer.response.nil? 
        render :template => "/users/biz_negotiate"  
      else
        render :template => "/users/counter_offer"   
      end 
    end 
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Account does not exist!!"
      redirect_to biz_dashboard_path
    end  
  end


  def show_account
    @user_all_acocunts =  current_user.user_accounts
    begin
    if params[:id]
      @current_account = UserAccount.find(params[:id])
      session[:account_id] = params[:id]
    elsif session[:account_id]
      @current_account = UserAccount.find(session[:account_id])
    else
      redirect_to root_path  
    end  
      if current_user.profile
        if !current_user.user_accounts.blank?
           @user_all_acocunts =  current_user.user_accounts
           if session[:account_id]
             @current_account = current_user.user_accounts.current_user_account(session[:account_id])
             #Cunsumer's Offer
             @offer = Offer.offer_of_current_user_account(current_user.id,@current_account.id,"")

             #Merchant Offer

             @system_offer = Offer.offer_of_current_user_account(current_user.id,@current_account.id,"IS NULL").first
             @consumer_first_offer = Offer.first(:conditions=>["user_id= ? && user_account_id = ? && response = 'counter'",current_user.id,@current_account.id])
             @counter_offer = Offer.counter_offer_of_current_user_account(current_user.id,@current_account.id).last
             @all_merchant_offers = Offer.offer_of_current_user_account(current_user.id,@current_account.id,"IS NULL")
             @merchant_offer = @all_merchant_offers.last
             @latest_offer = @offer.last 
             @paid_offer = Payment.find_by_offer_id(@latest_offer.id)          
             @all_offers = Offer.offer_of_current_user_account(current_user,@latest_offer.user_account_id,"")
             case @latest_offer.status.to_i
             when 1
               @payment = @latest_offer.payment || Payment.create(:offer_id => @latest_offer.id,:amount=>@latest_offer.amount,:status=>Payment::PAYMENT_STATUS[:pending],:transaction_id => "",:user_id=>current_user.id)
               flash[:notice] = "We sent this offer to your creditor"
               render :template => "/users/settlement"
               #render :template => "/users/biz_negotiate"
             when 2
               render :template => "/users/reject_offer"  
             else
               if @all_offers.count > 1
                 if @latest_offer.response.nil?
                   render :template => "/users/first_offer"  
                  else
                    flash[:notice] = "We made the offer to your creditor!"
                    render :template => "/users/negotiate"  
                  end   
               else
                 render :template => "/users/first_offer"  
               end  
             end   
            else 
           end 
        else
           @user_account = UserAccount.new
           @term_condition = true
           render :template => "/users/user_account",:term_condition=>true
        end   
      else
        @profile = Profile.new
        render :template => "/users/consumer_profile",:id=>"test"
      end  
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "User Account does not exist!!"
        redirect_to root_path
      end  
  end

  def create_user_account
      @user_account = UserAccount.new(params[:user_account])
      if @user_account.valid?
        @user_account.amount = params[:user_account][:amount].gsub(/\D+/, "").to_i      
        @user_account.user_id = current_user.id
        if @user_account.save
          flash[:notice] = "Thanks. We saved this information and will attempt to settle your debt"    

          create_offer

          if params[:add_account]
            @term_condition = nil 
            @user_account = UserAccount.new
            render :template => "/users/user_account"   
          else
            redirect_to root_path
          end    
        else  
          if @user_account.errors.first[0] == 'term_condition'
           @term_condition = true
           flash[:error] = "Terms and Conditions must be accepted"  
          else           
            @term_condition = true
           flash[:error] = "Please enter your account information"
          end  
           render 'user_account'
        end
      else
        @term_condition = true
        flash[:error] = "Please enter your account information"
        render 'user_account'
      end  
  end


  def biz_negotiate

    @current_account = UserAccount.find(params[:current_account_id])
    @account_user = @current_account.user
    @offer = Offer.offer_of_current_user_account(@account_user.id,@current_account.id,"").last
    @biz_offers = Offer.offer_of_current_user_account(@account_user.id,@current_account.id,"IS NULL")
    @system_offer = Offer.offer_of_current_user_account(@account_user.id,@current_account.id,"IS NULL").first
    @offer_status = params[:submit_button]
    @return_status = @account_user.valid_offer(@offer_status)
    @consumer_offers = Offer.counter_offer_of_current_user_account(@current_account.user.id,@current_account)

      unless @offer_status == "offer"
        case @return_status.to_i
        when 1
          @any_other_offers = Offer.offer_of_current_user_account(@account_user.id,params[:current_account_id],"")
          if @any_other_offers.size > 1
            @any_other_offers.each do |other_offer|
              other_offer.response = "expire"                            
              other_offer.save
            end
          end  
          @offer = Offer.create(:user_id=>@account_user.id,:user_account_id=>params[:current_account_id],:amount=>@offer.amount,:status=>Offer::OFFER_STATUS[:active])
          redirect_to :controller=>"users",:action=>"biz_show_account",:id=>session[:account_id]

        when 2
          @update_status = @offer.status_update(@return_status)
          redirect_to :controller=>"users",:action=>"biz_show_account",:id=>session[:account_id]
        end  
        UserMailer.deliver_update_notification_from_biz(@account_user)         
      else
        if params[:offer] and !params[:offer].strip.blank?
          amount = params[:offer].gsub(/\D+/, '')

          if @biz_offers.count <=1 
            if amount.to_i < @consumer_offers.last.amount.to_i || amount.to_i > @current_account.amount.to_i
              flash[:notice] = "Please offer more than Consumer first offer and less than Original amount"
              redirect_to :controller=>"users",:action=>"biz_show_account",:id=>session[:account_id]
            else
              @counter_offer = Offer.create({:user_id=>@offer.user_id,:user_account_id=>@offer.user_account_id,:amount=>amount,:status=>Offer::OFFER_STATUS[:pending]})
              redirect_to :controller=>"users",:action=>"biz_show_account",:id=>session[:account_id]

              UserMailer.deliver_update_notification_from_biz(@account_user)
            end
          else
            if @offer &&  amount.to_i < @biz_offers.last.amount.to_i
              @counter_offer = Offer.create({:user_id=>@offer.user_id,:user_account_id=>@offer.user_account_id,:amount=>amount,:status=>Offer::OFFER_STATUS[:pending]})
              redirect_to :controller=>"users",:action=>"biz_show_account",:id=>session[:account_id]

              UserMailer.deliver_update_notification_from_biz(@account_user)
            else
              flash[:notice] = "Please make sure your offer is lower than your last offer"
              redirect_to :controller=>"users",:action=>"biz_show_account",:id=>session[:account_id]
            end
          end
        else
          flash[:error] = "Please make an offer"
          redirect_to root_path        
        end
        #   amount = params[:offer].gsub(/\D+/, '')
        #   if @offer
        #    @counter_offer = Offer.create({:user_id=>@offer.user_id,:user_account_id=>@offer.user_account_id,:amount=>amount,:status=>Offer::OFFER_STATUS[:pending]})
        #    redirect_to :controller=>"users",:action=>"biz_show_account",:id=>session[:account_id]
        #   end
        #   UserMailer.deliver_update_notification_from_biz(@account_user)
        # else
        #   flash[:error] = "Please make an offer"
        #   redirect_to root_path        
        # end 
      end      
  end


  def negotiate
    if request.post?
      @user = current_user
      @current_user_account = params[:current_account_id]
      @user_account_data = UserAccount.find_by_id(@current_user_account)
      @offer_status = params[:submit_button]
      @return_status = @user.valid_offer(@offer_status)


      @offer = Offer.offer_of_current_user_account(current_user,@current_user_account,"IS NULL").last
      #@any_other_offers = Offer.offer_of_current_user_account(current_user.id,@current_user_account,"")
      unless @offer_status == "offer"
        case @return_status.to_i
        when 0
          flash[:notice] = "Your Offer is Pending "
        when 1
          @any_other_offers = Offer.offer_of_current_user_account(current_user.id,@current_user_account,"")
          if @any_other_offers.size > 1
            @any_other_offers.each_with_index do |other_offer,index|
              index = index + 1
              if index < @any_other_offers.size
                other_offer.response = "expire"                            
                other_offer.save
              end  
            end
          @payment = @offer.payment || Payment.create(:offer_id => @offer.id,:amount=>@offer.amount,:status=>Payment::PAYMENT_STATUS[:pending],:transaction_id => "",:user_id=>current_user.id)
          @update_status = @offer.status_update(@return_status)

          flash[:notice] = "Offer Accepted "  
          redirect_to :controller=>"users",:action=>"show_account",:id=>session[:account_id]
         else
          amount = @any_other_offers.last.amount
          @last_offer = Offer.offer_of_current_user_account(current_user,@current_user_account,"").last
          @counter_offer = Offer.create({:user_id=>@any_other_offers.last.user_id,:user_account_id=>@any_other_offers.last.user_account_id,:amount=>amount,:status=>Offer::OFFER_STATUS[:pending],:response=>"counter"})
          redirect_to :controller=>"users",:action=>"show_account",:id=>session[:account_id]
         end
        when 2
          @update_status = @offer.status_update(@return_status)
          params[:data] = @update_status
          redirect_to :controller=>"users",:action=>"show_account",:id=>session[:account_id]
        else
          puts "something wrong"  
          redirect_to :controller=>"users",:action=>"show_account",:id=>session[:account_id]
        end
        #redirect_to :controller=>"users",:action=>"show_account",:id=>session[:account_id]
      else  
        if params[:offer] and !params[:offer].strip.blank?
          amount = params[:offer].gsub(/\D+/, '')

          @offer = Offer.offer_of_current_user_account(current_user,@current_user_account,"")
          @consumer_offers = Offer.counter_offer_of_current_user_account(current_user,@current_user_account)

          @last_offer = @offer.last

          if @offer && @offer.count <= 1
            if amount.to_i >= @last_offer.amount.to_i 
              amount = @last_offer.amount
              @counter_offer = Offer.create({:user_id=>@last_offer.user_id,:user_account_id=>@last_offer.user_account_id,:amount=>amount,:status=>Offer::OFFER_STATUS[:pending],:response=>"counter"})                
              flash[:notice] = "We sent the lower (recommended) offer to your creditor"
              redirect_to :controller=>"users",:action=>"show_account",:id=>session[:account_id]               
            else
              @counter_offer = Offer.create({:user_id=>@last_offer.user_id,:user_account_id=>@last_offer.user_account_id,:amount=>amount,:status=>Offer::OFFER_STATUS[:pending],:response=>"counter"})
              redirect_to :controller=>"users",:action=>"show_account",:id=>session[:account_id]               
            end
          else
            if @offer && amount.to_i <= @consumer_offers.last.amount.to_i || amount.to_i > @user_account_data.amount.to_i
              flash[:notice] = "Please offer more than last time- or Yes to agree or No to end"
              redirect_to :controller=>"users",:action=>"show_account",:id=>session[:account_id]
            else
              @counter_offer = Offer.create({:user_id=>@last_offer.user_id,:user_account_id=>@last_offer.user_account_id,:amount=>amount,:status=>Offer::OFFER_STATUS[:pending],:response=>"counter"})
              redirect_to :controller=>"users",:action=>"show_account",:id=>session[:account_id]              
            end              
          end
        else
          flash[:error] = "Please make an offer"
          redirect_to :controller=>"users",:action=>"show_account",:id=>session[:account_id]
        end
        #   if @offer && amount.to_f < @last_offer.amount
        #    @counter_offer = Offer.create({:user_id=>@offer.user_id,:user_account_id=>@offer.user_account_id,:amount=>amount,:status=>Offer::OFFER_STATUS[:pending],:response=>"counter"})
        #    redirect_to :controller=>"users",:action=>"show_account",:id=>session[:account_id]
        #  else
        #    #@return_status = 1
        #    #@payment = @offer.payment || Payment.create(:offer_id => @offer.id,:amount=>@offer.amount,:status=>Payment::PAYMENT_STATUS[:pending],:transaction_id => "",:user_id=>current_user.id)
        #    #@update_status = @last_offer.status_update(@return_status)
        #    #flash[:notice] = "Offer `Accepted "  
        #    flash[:error] = "Please offer more than last
        #                     time- or Yes to agree or No to end"
        #    redirect_to :controller=>"users",:action=>"show_account",:id=>session[:account_id]
        #   end
        # else
        #   flash[:error] = "Please make an offer"
        #   redirect_to :controller=>"users",:action=>"show_account",:id=>session[:account_id]
        # end
      end
    end
  end

  def create_offer
    @offer = Offer.new()

    case @user_account.debt_period
    when 0    #Less than 1 Year
      @first_offer = @user_account.amount.to_f * 0.80
    when 1    #Between 1 to 5 years
      @first_offer = @user_account.amount.to_f * 0.60
    when 2    #More than 5 years
      @first_offer = @user_account.amount.to_f * 0.50
    else  
      puts "Something Wrong"
    end
    @offer.user_id = current_user.id
    @offer.user_account_id = @user_account.id
    @offer.amount = @first_offer.ceil
    @offer.status = Offer::OFFER_STATUS[:pending]
    @offer.save

  end


 def notify

  notify = Paypal::Notification.new(request.raw_post)

  if notify.acknowledge
    @payment = Payment.find_by_id(params[:payment_id])
    begin
      @payment.transaction_id = notify.transaction_id
      if notify.complete?
        @payment.status = Payment::PAYMENT_STATUS[:success]
      else
        logger.error("Failed to verify Paypal's notification, please investigate")
      end
      rescue => e
      ensure
        @payment.save
    end  
    flash[:notice] = "Payment Successful"
    redirect_to root_path
  end

  render :text => "done"

 end

 def success_return
   flash[:notice] = "Payment Successful"
   redirect_to root_path
 end

 def cancel_return

  flash[:error] = "Payment Cancel"
  redirect_to root_path

 end

 #def email_sent_from_biz

 #end


def forgot
    flash[:error] = nil
    email = params[:user][:email]
    if request.post?
      if email and !email.strip.blank?
        @user = User.find_by_email(email)
        if @user.nil?
          flash[:error] = "No such ID, want to join?"
        else
          UserMailer.deliver_forgot_password(@user)
          flash[:notice] = "Yeah! Emailed you the password."
          redirect_to root_path
        end
      else
        flash[:error] = "Please enter valid information"
      end
     end 
  end

end
