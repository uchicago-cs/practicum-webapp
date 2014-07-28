class QuartersController < ApplicationController

  load_and_authorize_resource

  before_action :downcase_season, only: :create
  before_action :is_admin?, only: [:new, :create]
  before_action :quarter_belongs_to_projects?, only: :destroy

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

  def edit
  end

  def update
    if @quarter.update_attributes(quarter_params)
      flash[:notice] = "Successfully updated quarter to #{@quarter.formatted_quarter}."
      redirect_to quarters_path
    else
      flash[:alert] = "Failed to update the quarter #{@quarter.formatted_quarter}."
      render 'edit'
    end
  end

  def destroy
    if @quarter.destroy
      flash[:notice] = "Successfully deleted quarter."
      redirect_to quarters_path
    else
      flash[:alert] = "Unable to delete quarter."
      render 'index'
    end
  end

  private

  def quarter_params
    params.require(:quarter).permit(:season, :year, :current)
  end

  def downcase_season
    @quarter.season.downcase!
  end

  def quarter_belongs_to_projects?
    if @quarter.projects.count > 0
      flash[:alert] = "Projects have already been made in this quarter, "\
      "so you cannot delete it."
      redirect_to quarters_path
    end
  end

end
