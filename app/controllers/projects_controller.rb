class ProjectsController < ApplicationController

  load_and_authorize_resource
  # Load the resource the viewer is trying to view and authorize
  # based on the viewer's role (and whether the viewer is logged in.)

  def new
  end

  def create
    @project = current_user.projects.build(project_params)
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
  end

  def show
  end

  def unapproved
    @unapproved_projects = Project.where(approved: false)
    # `false` means "not yet approved".
  end

  def approve
    if @project.update_attributes(approved: true)
      flash[:notice] = "Project approved."
      redirect_to project_path
    end
  end

  def disapprove
  end

  private

  def project_params
    params.require(:project).permit(:name, :description, :deadline)
  end

end
