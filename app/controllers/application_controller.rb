class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    #render :text => exception, :status => 500
    redirect_to root_url, alert: "Access denied: #{exception}"
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, flash: { error: "Access denied: #{exception}" }
  end

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

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

    devise_parameter_sanitizer.for(:sign_in) do |user|
      user.permit(:cnet, :email, :password, :remember_me)
    end
  end

  def is_admin?
    message = "Access denied."
    redirect_to root_url, flash: { error: message } and return unless
      current_user.admin?
  end

  # Why is this in both the controller and the helper?
  def before_deadline?(deadline)
    message = "The #{deadline} deadline for this quarter has passed."
    redirect_to root_url, flash: { error: message } unless
      DateTime.now <= Quarter.current_quarter.deadline(deadline)
  end

end
