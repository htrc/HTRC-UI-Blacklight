class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    auth = env["omniauth.auth"]
    Rails.logger.info("auth is **************** #{auth.to_yaml}")

    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_oauth(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "HTRC") if is_navigational_format?
    else
      session["devise.htrc_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def wso2
    auth = env["omniauth.auth"]
    Rails.logger.info("auth is **************** #{auth.to_yaml}")

    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_oauth(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "HTRC") if is_navigational_format?
    else
      session["devise.htrc_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def failure
    logger.debug "DEBUG REQUEST #{request.env}"
    logger.debug "DEBUG PARAMS #{params}" 
    render :text => params.inspect
  end
 
end
