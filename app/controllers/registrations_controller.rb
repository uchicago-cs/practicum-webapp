class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    super
  end

  # See https://github.com/plataformatec/devise/wiki/
  # How-To:-Allow-users-to-edit-their-account-without-providing-a-password
  def update
    super

    # account_update_params = devise_parameter_sanitizer.sanitize(:account_update)
    # if account_update_params[:password].blank?
    #   account_update_params.delete("password")
    #   account_update_params.delete("password_confirmation")
    # end

    # @user = User.find(current_user.id)
    # if @user.update_without_password(account_update_params)
    #   set_flash_message :notice, :updated
    #   # Sign in the user bypassing validation in case their password changed
    #   sign_in @user, :bypass => true
    #   redirect_to after_update_path_for(@user)
    # else
    #   render "edit"
    # end
  end

end
