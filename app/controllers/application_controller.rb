class ApplicationController < ActionController::Base

  # Adds a few additional behaviors into the application controller 
   include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 

  protect_from_forgery

  def get_header_params
    if (request.env["HTTP_X_FORWARDED_FOR"])
     {:headers => {"X-Forwarded-For"=> request.env["HTTP_X_FORWARDED_FOR"]} }
    else
      {:headers => {"X-Forwarded-For"=> request.env["REMOTE_ADDR"]} }
    end
  end

end
