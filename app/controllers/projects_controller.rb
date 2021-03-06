class ProjectsController < ApplicationController

  include ProjectPatterns
  include ProjectSubmissionPatterns

  load_and_authorize_resource

  skip_before_action :authenticate_user!,        only: [:index, :show]
  before_action      :redirect_if_no_quarters_exist, only: :index
  before_action      :get_status_published,      only: [:show, :update_status]
  before_action      :get_old_project_info,      only: :clone_project
  before_action      :can_create_projects?,      only: [:new, :create]
  before_action      :get_year_and_season,       only: [:new, :create, :edit,
                                                        :update]
  before_action      :redirect_if_no_quarter_params, only: :pending

  before_action(only: [:update_status, :update]) { |c|
    c.get_this_user_for_object(@project) }
  before_action(only: :show) { |c|
    c.redirect_if_wrong_quarter_params(@project) }

  def new
  end

  def create
    # If an admin is creating the advisor's project proposal, then
    # we figure out which advisor the admin is referring to.
    if params[:project][:proposer].present?
      create_record_for_target_user :proposer
    else
      # Otherwise, we just build the advisor's project normally.
      @project = current_user.projects.build(project_params)
    end

    @quarter = Quarter.find_by(year: params[:year], season: params[:season])
    @project.assign_attributes(quarter_id: @quarter.id)

    create_or_update_project :new
  end

  def edit
  end

  # Not DRY (see #create and submissions_controller.rb), and a bit too much
  # logic.
  def update
    if @project.draft?
      # Edit the proposal while it's a draft
      @project.assign_attributes(project_params)
      create_or_update_project :edit
    else
      # Edit the proposal while it's submitted and pending
      if @project.update_attributes(project_params)
        flash[:success] = "Project proposal successfully updated."
        redirect_to project_path(@project, year: @project.quarter.year,
                                 season: @project.quarter.season)
      else
        render 'edit'
      end
    end
  end

  def destroy
  end

  def index
    if params[:year] and params[:season]
      # We're visiting a quarter-specific projects page
      @quarter = Quarter.where(year: params[:year],
                               season: params[:season]).take

      # Get the accepted published projects from this quarter
      @projects = Project.accepted_published_projects_in_quarter(@quarter)
    else
      # We're visiting the global projects page
      @projects = Project.current_accepted_published_projects

      # Filter the projects by quarter
      @grouped_projects = @projects.group_by(&:quarter)

      # Get the quarters with future start_dates
      @future_quarters = Quarter.future_quarters
    end
  end

  def show
  end

  def pending
    if params[:year] and params[:season]
      @year     = params[:year]
      @season   = params[:season]
      @quarter  = Quarter.where(year: @year, season: @season).take
      @projects = Project.unpublished_in_quarter(@quarter)
    else
      @projects = Project.current_unpublished_projects
    end
  end

  def update_status
    @db_project = Project.find(params[:id])

    status_strings = {
      "Accept"             => { attr: "status", val: "accepted",
                                txt: "accepted" },
      "Request changes"    => { attr: "status", val: "pending",
                                txt: "set to \"pending\"" },
      "Reject"             => { attr: "status", val: "rejected",
                                txt: "rejected" },
      "Unpublish decision" => { attr: "status_published", val: false,
                                txt: "unpublished" },
      "Publish decision"   => { attr: "status_published", val: true,
                                txt: "published" } }

    save_status(@db_project, @project, status_strings)
  end

  # Publish all proposals that are flagged as approved or rejected.
  # (They are "pending" in the sense that students cannot see them.
  # Note that their advisors can see them.)
  def publish_all_pending

    Project.unpublished_nonpending_projects.each do |project|
      # `@project` isn't defined here, so we're assigning this_user to each
      # project. For this reason, our `this_user` code could be better.
      project.this_user = current_user
      project.assign_attributes(status_published: true)
      if project.invalid?
        flash.now[:error] = "Unable to publish all flagged project statuses."
        render 'pending' and return
      else
        project.save
      end
    end

    flash[:success] = "Published all flagged project statuses."
    redirect_to pending_projects_path(year: params[:year],
                                      season: params[:season])
  end

  # `clone` is a keyword, so we use #clone_project instead of #clone.
  def clone_project
    @new_project = @old_project.dup
    @new_project.assign_attributes(quarter_id: Quarter.active_quarter.id,
                                   status: "pending",
                                   status_published: false)
    if @new_project.save
      @old_project.update_attributes(cloned: true)
      flash[:success] = "Project successfully cloned."
      # We use `project_path(@new_project)` instead of simply `@new_project`
      # as per the Brakeman redirect warning.
      redirect_to project_path(@new_project)
    else
      flash.now[:error] = "Project was not successfully cloned."
      render 'show'
    end
  end

  private

  def project_params
    as = [:name, :description, :expected_deliverables, :prerequisites,
          :related_work, :comments, :cloned]
    as += [:status, :status_published, :advisor] if current_user.admin?

    if current_user.admin? or current_user.advisor?
      params.require(:project).permit(*as)
    end
  end

  def get_status_published
    @project_status_published = @project.status_published
  end

  def get_old_project_info
    @old_project = Project.find(params[:id])
    @old_project.this_user = current_user
  end

  def can_create_projects?
    if Quarter.active_exists? and !current_user.admin?
      before_deadline?("project_proposal", params[:year], params[:season])
    elsif !current_user.admin?
      redirect_to root_url, flash: { error: "This quarter is inactive." } and
        return
    end
  end

  def redirect_if_no_quarter_params
    if !params[:year] or !params[:season]
      flash[:error] = "You may only view pending projects in specific quarters."
      redirect_to root_path and return
    end
  end
end
