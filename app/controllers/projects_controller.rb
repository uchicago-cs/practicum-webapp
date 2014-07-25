class ProjectsController < ApplicationController

  load_and_authorize_resource

  skip_before_action :authenticate_user!, only: [:index, :show]

  def new
  end

  def create
    @project = current_user.projects.build(project_params)
    @project.quarter_id = Quarter.current_quarter.id

    if @project.save
      flash[:notice] = "Project successfully proposed."
      redirect_to current_user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @project.update_attributes(project_params)
      flash[:notice] = "Project proposal successfully updated."
      redirect_to @project
    else
      render 'edit'
    end
  end

  def destroy
  end

  def index
    @projects = Project.current_accepted_projects
  end

  def show
  end

  def pending
    @pending_projects = Project.pending_projects
  end

  def edit_status
  end

  def update_status
    if @project.update_attributes(project_params)
      flash[:notice] = "Project status changed."
      redirect_to project_path
    else
      render 'edit_status'
    end
  end

  private

  def project_params
    params.require(:project).permit(:name, :description, :deadline, :status,
                                    :expected_deliverables, :prerequisites,
                                    :related_work, :comments)
  end

end
