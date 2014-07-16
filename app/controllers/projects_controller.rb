class ProjectsController < ApplicationController

  load_and_authorize_resource

  def new
  end

  def create
    @project = current_user.projects.build(project_params)
    if @project.save

      User.admins.each do |admin|
        Notifier.project_proposed(@project.advisor, 
                                  @project, admin).deliver
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
    @projects = Project.accepted_projects
  end

  def show
  end

  def pending
    @pending_projects = Project.pending_projects
  end

  def accept
    if @project.update_attributes(status: "accept")
      Notifier.project_accepted(@project.advisor,
                                @project).deliver
      flash[:notice] = "Project accepted."
      redirect_to project_path
    end
  end

  def reject
  end

  private

  def project_params
    params.require(:project).permit(:name, :description, :deadline, :status)
  end

end
