class UsersController < ApplicationController

  load_and_authorize_resource

  before_action :is_admin?, only: :index

  def show
  end

  def index
  end

  def edit
  end

  def update
  end

  def submissions_made
  end

  def projects_created
  end

  private

  def is_admin?
    redirect_to root_url unless current_user.admin?
  end

end
