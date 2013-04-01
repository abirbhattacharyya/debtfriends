# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  # render new.erb.html
  def new
    @user = User.new
    session[:path] = ""
    if logged_in?
      redirect_to root_path
      return
    end 
  end

  def biz_new 
    @user = User.new
    session[:path] = request.path
    if logged_in?
      redirect_to root_path
      return
    end 
  end

  def create_biz
    if params[:submit_type].to_i == 1
      email = params[:user][:email]
      if email and !email.strip.blank?
        @user = User.find_by_email(email)
        if @user && @user.biz?          
          UserMailer.deliver_forgot_password(@user)
          flash[:notice] = "We just emailed you the password!"
          redirect_to biz_path
        else  
          flash[:error] = "No such Email, want to join? Thanks"
          redirect_to biz_path
        end
      else
        flash[:error] = "Please enter valid information"
        redirect_to biz_path
      end
    else
      if ((params[:user][:email]) || (params[:user][:crypted_password])) == ""
        flash[:error] = "Invalid username/password"  
        redirect_to biz_path
      else    
         @user = User.new
         valid_pass = @user.check_pass(params[:user][:crypted_password])
         if valid_pass == false
           flash[:error] = "Please enter a valid password"  
           redirect_to biz_path
         else   
           user = User.user_authenticate(params[:user][:email])
          if user
            if user.biz?
              if user.matching_password?(params[:user][:crypted_password])
                self.current_user = user
                redirect_to biz_dashboard_path
              else
                flash[:error] = "Please enter a valid password"  
                redirect_to biz_path
              end
            else
              flash[:error] = "Please enter valid information"  
              redirect_to biz_path
            end  
          else
            if params[:user][:email] == ""
              flash[:error] = "Please enter a valid email"  
              redirect_to biz_path
            else  
              create_biz_user()
              flash.now[:notice] = "Logged in not successfully"         
            end
          end
         end 
      end  
    end
  end

  def create
    if params[:submit_type].to_i == 1
      email = params[:user][:email]
      if email and !email.strip.blank?
        @user = User.find_by_email(email)
        if @user
          if @user.biz?
            flash[:error] = "No such Email, want to join? Thanks"
            redirect_to login_path
          else  
            UserMailer.deliver_forgot_password(@user)
            flash[:notice] = "We just emailed you the password!"
            redirect_to login_path
          end  
        else
          flash[:error] = "No such Email, want to join? Thanks"
          redirect_to login_path
        end
      else
        flash[:error] = "Please enter valid information"
        redirect_to login_path
      end
    else
      if ((params[:user][:email]) || (params[:user][:crypted_password])) == ""
        flash[:error] = "Invalid username/password"  
        render :action => :new
      else
        @user = User.new
         valid_pass = @user.check_pass(params[:user][:crypted_password])
         if valid_pass == false
           flash[:error] = "Please enter a valid password"  
#	           redirect_to root_path
		       render :action => :new
         else   
           user = User.user_authenticate(params[:user][:email])

          unless user.nil?
            if !user.biz?
              if user.matching_password?(params[:user][:crypted_password])
                self.current_user = user
                redirect_to root_path
              else
                flash[:error] = "Please enter a valid password"  
#	           redirect_to root_path
		       render :action => :new
              end
            else
              flash[:error] = "Please enter valid information"  
#	           redirect_to root_path
		       render :action => :new
            end  
          else
            if params[:user][:email] == ""
              flash[:error] = "Please enter a valid email"  
#	           redirect_to root_path
		       render :action => :new
            else  
              create_user()
              flash.now[:notice] = "Logged in not successfully"         
            end
          end
        #end  
      end
    end  
  end
  end

  def create_biz_user
    @user = User.new(params[:user])
    @user.prepare_password
    @user.status = "business"
    if @user.save
     self.current_user = @user # !! now logged in
     redirect_to biz_dashboard_path
    else
      @user = User.new
      flash[:error] = "Please enter valid information"
      redirect_to biz_path
    end   
  end

  def create_user
    @user = User.new(params[:user])
    @user.prepare_password
    if @user.save
     self.current_user = @user # !! now logged in
     redirect_to root_path
    else
      @user = User.new
      flash[:error] = "Please enter valid information"
      render :action => :new
    end
  end

  def destroy
   if current_user && current_user.status == "business"
      logout_killing_session!
      redirect_to biz_path
    else
      logout_killing_session! 
      redirect_to root_path
    end  
    flash[:notice] = "You have been logged out."
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
