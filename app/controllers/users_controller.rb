class UsersController < ApplicationController

  load_and_authorize_resource

  before_action :is_admin?,                only: :index
  before_action :prevent_self_demotion,    only: :update
  before_action(only: :update) { |c| c.get_this_user_for_object(@user) }

  def show
  end

  def index
    if params[:approved] == "false"
      @users = User.where(approved: false).page(params[:page])
    else
      @users = User.all.page(params[:page])
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      if params[:user][:advisor] == "1" and @user.advisor_status_pending?
        @user.update_attributes(advisor_status_pending: false)
      end
      flash[:success] = "Settings successfully updated."
      redirect_to @user
    else
      render 'show'
    end
  end

  # For a specific quarter
  def my_projects
  end

  # For a specific quarter
  def my_submissions
  end

  # All of this user's projects
  def my_projects_all
  end

  # All of this user's applications
  def my_submissions_all
  end

  private

  def user_params
    if current_user.admin?
      params.require(:user).permit(:student, :advisor, :admin,
                                   :affiliation, :department, :approved)
    else
      if current_user.advisor?
        params.require(:user).permit(:affiliation, :department)
      end
    end
  end

  def prevent_self_demotion
    if params[:id].to_i == current_user.id and
        params[:user][:admin]              and
        params[:user][:admin].to_i == 0    and
        current_user.admin?
      message = "You cannot demote yourself."
      redirect_to @user, flash: { error: message }
    end
  end

end
