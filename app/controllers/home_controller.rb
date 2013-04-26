class HomeController < ApplicationController
  before_filter :check_normal_login,:only=>[:my_agreements,:my_statistics,:biz_statistics]

  def index
  	if logged_in?
      if !current_user.biz?
  		  if current_user.profile
          if !current_user.user_accounts.blank?
             @user_all_acocunts =  current_user.user_accounts
             #(:conditions=>["status not in (?)",Offer::OFFER_STATUS[:pending]])
             #Topic.find(:all, :conditions => ['forum_id not in (?)', @forums.map(&:id)])
          else 
             @user_account = UserAccount.new
             @term_condition = true
             render :template => "/users/user_account",:term_condition=>true
          end   
  		  else
          @profile = Profile.new
  		    render :template => "/users/consumer_profile",:id=>"test"
  		  end  
      else
        redirect_to biz_dashboard_path
      end   
  	else
     if request.path == "/biz3795"
      redirect_to biz_path
     else 
     end
    end	  		
  end

  def fill_debt
  end

  def my_agreements
    #@active_offers = Offer.all(:conditions => ["user_id = ? && response IS NULL && status = 1", current_user.id])
    @active_offers = Offer.all(:conditions => ["user_id = ? && status = 1", current_user.id])
  end

  def biz_my_agreements
    @user_com  =  BizCompany.find_by_user_id(current_user.id)
    @company_users = UserAccount.all(:conditions=>["company_name = ?",@user_com.company_name])
    @active_offers = Offer.all(:conditions => ["user_id = ? && response IS NULL && status = 1", current_user.id])
  end


  def change_days
    current_time = Time.now.in_time_zone("Pacific Time (US & Canada)")
    @month = params[:month].to_i

    @day_range = Array.new
    if current_time.month == @month

      @day_range = day_options
      @day = current_time.day
      @year = current_time.year
    else


      next_month = current_time + 30.days
      from_day = next_month.beginning_of_month.day
      end_day = next_month.day
      from_day.upto(end_day) do|day|
        @day_range.push(day)
      end
      @year = next_month.year
    end

  end

  def biz_statistics
    @user_com  =  BizCompany.find_by_user_id(current_user.id)
    @company_users = UserAccount.all(:conditions=>["company_name = ?",@user_com.company_name])

  end

  def my_statistics
    if request.post?
      @page = params[:page].to_i
    else
      @page = 1
    end

    @size = 2
    @per_page = 1
    @post_pages = (@size.to_f/@per_page).ceil;
    @page =1 if @page.to_i<=0 or @page.to_i > @post_pages
	  #@chart_h1_title = "Look at your cool analytics!(#{@page} of #{@size})"
    @chart_h1_title = "Here are your current debts and offers on the system"
    @chart_h2_title = "Here are your potential % & $ savings"
    @titleX = "Debts"
    @titleY = "Offers"
    @colors = []

    @all_debts = UserAccount.all(:conditions => ["user_id = ?", current_user.id]) 
    @all_offers = Offer.all(:conditions => ["user_id = ? && response = 'counter'", current_user.id])



    @titleY = ""
    @total_debt = 0
    @total_offer_amount = 0
    @chart_h2_title = "Here are your potential % & $ savings"

    @accept_offer = Offer.all(:conditions => ["user_id = ? && status=1", current_user.id])
    @total_offer = Offer.all(:conditions => ["user_id = ?", current_user.id],:group => :user_account_id)
    @account_debt_amount = 0 


    unless @accept_offer.blank?
      @accept_offer.each do |offer|
        @debt = offer.user_account
        @debt_amount = @debt.amount
        @total_debt = @debt_amount + @total_debt
        @total_offer_amount = @total_offer_amount + offer.amount.to_i
      end   
      @save_amount_in_dollar = @total_debt - @total_offer_amount     
      @save_amount_in_percentage = (100 * @save_amount_in_dollar) / @total_debt
    else
      @save_amount_in_dollar = 0
      @save_amount_in_percentage = 0.00
    end  
  end
end
