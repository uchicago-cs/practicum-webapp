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
    if @quarter.save
      flash[:success] = "Quarter successfully created."
      redirect_to quarters_path
    else
      # We need #now since we are rendering and not redirecting (not making an
      # extra request).
      flash.now[:error] = "Quarter could not be created."
      render 'new'
    end
  end

  def edit
  end

  def update
    @quarter.attributes = quarter_params
    if @quarter.save
      flash[:success] = "Quarter successfully updated."
      redirect_to quarters_path
    else
      flash.now[:error] = "Failed to update the quarter."
      render 'edit'
    end
  end

  def destroy
    redirect_to quarters_path and return if @quarter.current?
    if @quarter.destroy
      flash[:success] = "Quarter successfully deleted."
      redirect_to quarters_path and return
    else
      flash.now[:error] = "Failed to delete the quarter."
      render 'index'
    end
  end

  private

  def quarter_params
    params.require(:quarter).permit(:season, :year, :current,
                                    :project_proposal_deadline,
                                    :student_submission_deadline,
                                    :advisor_decision_deadline,
                                    :start_date, :end_date,
                                    :admin_publish_deadline)
  end

  def downcase_season
    @quarter.season.downcase!
  end

  def quarter_belongs_to_projects?
    if @quarter.projects.count > 0
      flash[:error] = "Projects have already been made in this quarter, "\
      "so you cannot delete it."
      redirect_to quarters_path
    end
  end

end
