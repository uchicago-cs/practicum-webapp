class ProjectsController < ApplicationController

  load_and_authorize_resource

  skip_before_action :authenticate_user!,        only: [:index, :show]
  before_action(only: [:new, :create]) { |c|
    c.before_deadline?("project_proposal") }
  before_action      :get_status_published,      only: [:show,
                                                        :update_status]
  before_action      :get_old_project_info,      only: :clone_project
  before_action      :get_this_user,             only: [:update_status,
                                                        :update]

  def new
  end

  def create
    @project = current_user.projects.build(project_params)
    @project.assign_attributes(quarter_id: Quarter.current_quarter.id)

    if @project.save
      flash[:success] = "Project successfully proposed."
      redirect_to users_projects_path(current_user)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @project.update_attributes(project_params)
      flash[:success] = "Project proposal successfully updated."
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

  def update_status
    if @project.update_attributes(project_params)
      flash[:success] = "Project status changed."
      redirect_to project_path
    else
      render 'show'
    end
  end

  def publish_all_pending
    projects = Project.current_pending_projects.where.not(status: "pending")

    projects.each do |project|
      project.status_published = true
      if project.invalid?
        flash.now[:error] = "Unable to publish all flagged project statuses."
        render 'pending' and return
      end
    end

    flash[:success] = "Published all flagged project statuses."
    redirect_to pending_projects_path
  end

  # `clone` is a keyword, so we use #clone_project instead of #clone.
  def clone_project
    @new_project = @old_project.dup
    @new_project.assign_attributes(quarter_id: Quarter.current_quarter.id,
                                   status: "pending",
                                   status_published: false)
    if @new_project.save
      @old_project.update_attributes(cloned: true)
      flash[:success] = "Project successfully cloned."
      redirect_to @new_project
    else
      flash.now[:error] = "Project was not successfully cloned."
      render 'show'
    end
  end

  private

  def project_params
    if current_user.admin?
      params.require(:project).permit(:name, :description, :status,
                                      :expected_deliverables, :prerequisites,
                                      :related_work, :comments, :cloned,
                                      :status_published)
    elsif current_user.advisor?
      params.require(:project).permit(:name, :description,
                                      :expected_deliverables, :prerequisites,
                                      :related_work, :comments, :cloned)
    end
  end

  def get_status_published
    @project_status_published = @project.status_published
  end

  def get_old_project_info
    @old_project = Project.find(params[:id])
    @old_project.this_user = current_user
  end

  def get_this_user
    @project.this_user = current_user
  end
end
