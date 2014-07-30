class UsersController < ApplicationController

  load_and_authorize_resource

  before_action :is_admin?, only: :index
  before_action :prevent_self_demotion, only: :update

  def show
  end

  def index
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:notice] = "Settings successfully updated."
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

  def prevent_self_demotion
    if params[:id].to_i == current_user.id and
        params[:user][:admin].to_i == 0 and
        current_user.admin?
      message = "You cannot demote yourself."
      redirect_to @user, notice: message
    end
  end

end
