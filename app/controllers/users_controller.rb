class UsersController < ApplicationController

  load_and_authorize_resource

  before_action :is_admin?, only: [:index]

  # Ensure user cannot set self to admin, advisor, etc.
  # See, e.g., http://stackoverflow.com/a/8980190/3723769

  def show
    # Grab projects and submissions instance variables (using #where)
    # here?
  end

  def index
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:notice] = "User roles successfully updated."
      redirect_to @user
    else
      render 'show'
    end
  end

  def submissions_made
  end

  def projects_created
  end

  private

  # def is_admin?
  #   redirect_to root_url unless current_user.admin?
  # end

  def user_params
    if current_user.admin?
      params.require(:user).permit(:student, :advisor, :admin,
                                   :affiliation, :department)
    else
      if current_user.advisor?
        params.require(:user).permit(:affiliation, :department)
      end
    end
  end

end
