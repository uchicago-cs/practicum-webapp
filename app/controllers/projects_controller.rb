class ProjectsController < ApplicationController

  load_and_authorize_resource

  def new
  end

  def create
    @project = current_user.projects.build(project_params)
    if @project.save

      User.admins.each do |admin|
        Notifier.project_proposed(@project.advisor, @project, admin)
      end
      
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
    @projects = Project.approved_projects
  end

  def show
  end

  def unapproved
    @unapproved_projects = Project.unapproved_projects
  end

  def approve
    if @project.update_attributes(approved: true)
      Notifier.project_approved(@project.advisor, @project)
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
