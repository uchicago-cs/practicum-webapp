class ProjectsController < ApplicationController

  load_and_authorize_resource

  skip_before_action :authenticate_user!,        only: [:index, :show]
  before_action      :before_proposal_deadline?, only: [:new, :create]

  def new
  end

  def create
    @project = current_user.projects.build(project_params)
    @project.assign_attributes(quarter_id: Quarter.current_quarter.id)

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
    @projects = Project.current_accepted_published_projects
  end

  def show
  end

  def pending
    @current_pending_projects = Project.current_pending_projects
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

  def publish_all_pending
    projects = Project.current_pending_projects.where.not(status: "pending")
    # #update_all skips validations!
    if projects.update_all(status_published: true)
      flash[:notice] = "Published all flagged project statuses."
      redirect_to pending_projects_path
    else
      flash[:alert] = "Unable to publish all flagged project statuses."
      render 'pending'
    end
  end

  def clone_project
    @old_project = Project.find(params[:id])
    @new_project = @old_project.dup
    @new_project.assign_attributes(quarter_id: Quarter.current_quarter.id,
                                   status: "pending")
    if @new_project.save
      @old_project.cloned = true
      @old_project.save
      flash[:notice] = "Project successfully cloned."
      redirect_to @new_project, only_path: true
    else
      flash[:alert] = "Project was not successfully cloned."
      render 'show'
    end
  end

  private

  def project_params
    if current_user.admin?
      params.require(:project).permit(:name, :description, :deadline, :status,
                                      :expected_deliverables, :prerequisites,
                                      :related_work, :comments, :cloned,
                                      :status_published)
    elsif current_user.advisor?
      params.require(:project).permit(:name, :description, :deadline,
                                      :expected_deliverables, :prerequisites,
                                      :related_work, :comments, :cloned)
    end
  end

end
