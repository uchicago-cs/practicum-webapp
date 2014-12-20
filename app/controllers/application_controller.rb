class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    redirect_to root_url, alert: "Access denied: #{exception}"
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, flash: { error: "Access denied: #{exception}" }
  end

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :show_advisor_status_pending_message
  before_action :redirect_if_invalid_quarter
  before_action :redirect_if_no_quarter_and_proposing_project

  helper_method :is_admin?
  helper_method :authenticate_user!
  helper_method :current_user

  def redirect_if_invalid_quarter
    if params[:year] and params[:season]
      if Quarter.where(year: params[:year], season: params[:season]).empty?
        redirect_to root_url, flash: { error: "That quarter does not exist." }
      end
    end
  end

  # TODO: Prevent access to this page and the post action in routes.rb.
  def redirect_if_no_quarter_and_proposing_project
    if not (params[:year] and params[:season])
      if request.path == "/projects/new"
        redirect_to root_url, flash:
          { error: "You must propose a project in a quarter." }
      end
    end
  end

  def authenticate_user!
    if ldap_user_signed_in?
      authenticate_ldap_user!
    elsif local_user_signed_in?
      authenticate_local_user!
    end
  end

  def current_user
    current_ldap_user or current_local_user
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) do |user|
      if current_user.admin?
        user.permit(:admin, :advisor, :student, :affiliation, :department,
                    :approved)
      elsif current_user.advisor?
        user.permit(:affiliation, :department)
      end
    end

    devise_parameter_sanitizer.for(:sign_in) do |user|
      user.permit(:cnet, :email, :password)
    end

    devise_parameter_sanitizer.for(:sign_up) do |user|
      user.permit(:email, :password, :password_confirmation,
                  :first_name, :last_name, :affiliation, :department)
    end
  end

  def is_admin?
    message = "Access denied."
    redirect_to root_url, flash: { error: message } and return unless
      current_user.admin?
  end

  def before_deadline?(deadline)
    if deadline == "student_submission"
      humanized_deadline = "application"
    else
      humanized_deadline = deadline.humanize.downcase
    end
    message = "The #{humanized_deadline} deadline for this quarter has passed."
    redirect_to root_url, flash: { error: message } unless
      DateTime.now <= Quarter.current_quarter.deadline(deadline)
  end

  def get_this_user_for_object(obj)
    obj.this_user = current_user
  end

  def show_advisor_status_pending_message
    if current_user and current_user.advisor_status_pending?
      message = "Your request to become an advisor is pending approval by " +
        "an administrator. You will be able to submit project proposals " +
        "once your request is approved."
      flash.now[:notice] = message
    end
  end

end
