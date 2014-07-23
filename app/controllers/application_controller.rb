class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, notice: "Access denied."
  end

  before_action :authenticate_user!

  helper_method :is_admin?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) do |user|
      if current_user.admin?
        user.permit(:admin, :advisor, :student, :affiliation, :department)
      else
        if current_user.advisor?
          user.permit(:affiliation, :department)
        end
      end
    end
  end

  def is_admin?
    redirect_to root_url unless current_user.admin?
  end

end
