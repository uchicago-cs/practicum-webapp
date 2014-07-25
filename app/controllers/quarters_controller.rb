class QuartersController < ApplicationController

  load_and_authorize_resource

  before_action :downcase_season, only: :create
  before_action :is_admin?, only: [:new, :create]

  def index
  end

  def show
    @quarter_projects = Project.quarter_accepted_projects(@quarter)
  end

  def new
  end

  def create
    @quarter.current = true
    if @quarter.valid?
      Quarter.set_current_false
      @quarter.save
      flash[:notice] = "Successfully set the current quarter."
      redirect_to current_user
    else
      flash[:notice] = "Unable to set the current quarter."
      render 'new'
    end
  end

  private

  def quarter_params
    params.require(:quarter).permit(:season, :year)
  end

  def downcase_season
    @quarter.season.downcase!
  end
end
