class Sessions::SessionsController < Devise::SessionsController
  prepend_before_filter :require_no_authentication, only: [ :new, :create ]
  prepend_before_filter :allow_params_authentication!, only: :create
  prepend_before_filter :verify_signed_out_user, only: :destroy
  prepend_before_filter only: [ :create, :destroy ] { request.env["devise.skip_timeout"] = true }

  # GET /resource/sign_in
  def new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    respond_with(resource, serialize_options(resource))
  end

  # POST /resource/sign_in
  def create
    # Adapted from http://stackoverflow.com/a/21175515/3723769.
    user_class = nil
    error_string = "Login failed"
    auth_attr = request.params['user']['auth_attr']

    if auth_attr.include?("@") or auth_attr.include?(".")
      user_class = :local_user
      auth_method = :email
      error_string = "Invalid E-mail or password."
    else
      user_class = :ldap_user
      auth_method = :cnet
      error_string = "Invalid CNetID or password."
    end

    request.params[user_class] = { auth_method => auth_attr,
      password: request.params['user']['password'] }

    ao = auth_options
    ao[:scope] = user_class
    self.resource = warden.authenticate(ao)

    if self.resource.nil?
      flash[:error] = error_string
      return redirect_to new_user_session_path
    end

    # If we make it here, the user is authenticated, and self.resource is a
    # valid user.

    set_flash_message(:success, :signed_in) if is_flashing_format?
    sign_in(user_class, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  # DELETE /resource/sign_out
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message :success, :signed_out if signed_out && is_flashing_format?
    yield if block_given?
    respond_to_on_destroy
  end

  protected

  def sign_in_params
    devise_parameter_sanitizer.sanitize(:sign_in)
  end

  def serialize_options(resource)
    methods = resource_class.authentication_keys.dup
    methods = methods.keys if methods.is_a?(Hash)
    methods << :password if resource.respond_to?(:password)
    { methods: methods, only: [:password] }
  end

  def auth_options
    { scope: resource_name, recall: "#{controller_path}#new" }
  end

  private

  # Check if there is no signed in user before doing the sign out.
  #
  # If there is no signed in user, it will set the flash message and redirect
  # to the after_sign_out path.
  def verify_signed_out_user
    if all_signed_out?
      set_flash_message :error, :already_signed_out if is_flashing_format?

      respond_to_on_destroy
    end
  end

  def all_signed_out?
    users = Devise.mappings.keys.map { |s| warden.user(scope: s, run_callbacks: false) }

    users.all?(&:blank?)
  end

  def respond_to_on_destroy
    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name) }
    end
  end
end
