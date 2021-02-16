class ApplicationController < ActionController::Base
  include SessionsHelper

  # Redirects to login if not signed in
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in"
      redirect_to login_path
    end
  end
  
end
