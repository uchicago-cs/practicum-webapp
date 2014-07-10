class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    # flash[:notice] = "Access denied."
    redirect_to root_url, notice: "Access denied."
    # If user is signed in, direct user to root_url.
    # If user is not signed in, direct user to sign in url. (new_user_ses?)
  end
end
