class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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
  before_action :redirect_if_no_quarter_and_new_record
  before_action :redirect_if_no_quarters_exist

  helper_method :is_admin?
  helper_method :authenticate_user!
  helper_method :current_user

  def redirect_if_wrong_quarter_params(obj)
    y = obj.quarter.year
    s = obj.quarter.season
    if params[:year].to_i != y or params[:season] != s
      redirect_to q_path(obj) and return
    end
  end

  def redirect_if_invalid_quarter
    if params[:year] and params[:season]
      if Quarter.where(year: params[:year], season: params[:season]).empty?
        redirect_to root_url, flash: { error: "That quarter does not exist." }
      end
    end
  end

  # TODO: Prevent access to this page and the post action in routes.rb. (?)
  def redirect_if_no_quarter_and_new_record
    # If the path is missing year and season params
    if request.path == new_project_path
      redirect_to root_url, flash:
        { error: "You must propose a project in a quarter." } and return
    end

    if (/\A\/projects\/\d\/applications\/new\Z/).match(request.path)
      redirect_to root_url, flash:
        { error: "You must apply to a project in a quarter." } and return
    end

    if (/\A\/submissions\/\d\/evaluations\/new\Z/).match(request.path)
      redirect_to root_url, flash:
        { error: "You must create an evaluation in a quarter." } and return
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

  def before_deadline?(dl, year = nil, season = nil)
    # Humanize the deadline type
    hdl = (dl == "student_submission") ? "application" : dl.humanize.downcase

    if year and season
      quarter = Quarter.find_by(year: year, season: season)
      e = quarter
      b = DateTime.now <= quarter.deadline(dl)
    else
      e = Quarter.active_exists?
      b = DateTime.now <= Quarter.active_quarter.deadline(dl)
    end

    message = "The #{hdl} deadline for this quarter has passed."
    redirect_to root_url, flash: { error: message } unless (b and e)
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

  def redirect_if_no_quarters_exist
    unless Quarter.all.present?
      unless [new_quarter_path, quarters_path, root_path].include? request.path
        flash[:error] = "There are no quarters. An admin must create a " +
          "quarter before the site can be used."
        redirect_to root_path and return
      end
    end
  end

end
