class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  # if Rails.env.production?
  #   unless Rails.application.config.consider_all_requests_local
  #     rescue_from Exception, with: :render_500
  #     rescue_from ActionController::RoutingError, with: :render_404
  #     rescue_from ActionController::UnknownController, with: :render_404
  #     rescue_from ActionController::UnknownAction, with: :render_404
  #     rescue_from ActiveRecord::RecordNotFound, with: :render_404
  #   end
  # end

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

  # def render_404(exception)
  #   @not_found_path = exception.message
  #   respond_to do |format|
  #     format.html { render template: 'errors/not_found',
  #                   layout: 'layouts/application', status: 404 }
  #     format.all { render nothing: true, status: 404 }
  #   end
  # end

  # def render_500(exception)
  #   logger.info exception.backtrace.join("\n")
  #   respond_to do |format|
  #     format.html { render template: 'errors/internal_server_error',
  #                   layout: 'layouts/application', status: 500 }
  #     format.all { render nothing: true, status: 500}
  #   end
  # end

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
    humanized_deadline = deadline.humanize.downcase
    message = "The #{humanized_deadline} deadline for this quarter has passed."
    redirect_to root_url, flash: { error: message } unless
      DateTime.now <= Quarter.current_quarter.deadline(deadline)
  end

  def get_this_user_for_object(obj)
    obj.this_user = current_user
  end

end
