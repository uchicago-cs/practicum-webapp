class ProjectsController < ApplicationController

  load_and_authorize_resource

  skip_before_action :authenticate_user!,        only: [:index, :show]
  before_action      :get_status_published,      only: [:show, :update_status]
  before_action      :get_old_project_info,      only: :clone_project
  before_action      :can_create_projects?,      only: [:new, :create]
  before_action      :get_year_and_season,       only: [:new, :create, :edit,
                                                        :update, :pending]
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
      proposing_user = params[:project][:proposer].downcase
      actual_user = (proposing_user.include? '@') ?
      User.find_by(email: proposing_user) :
        User.find_by(cnet: proposing_user)

      if actual_user
        @project = actual_user.projects.build(project_params)
        @project.proposer = proposing_user
        @project.assign_attributes(advisor: actual_user)
      else
        flash.now[:error] = "There is no user with that CNetID or E-mail " +
          "address."
        render 'new' and return
      end

      if !actual_user.advisor?
        flash.now[:error] = "That user is not an advisor."
        render 'new' and return
      end

    else
      # Otherwise, just build the advisor's project normally.
      @project = current_user.projects.build(project_params)
    end

    @quarter = Quarter.find_by(year: params[:year], season: params[:season])
    @project.assign_attributes(quarter_id: @quarter.id)

    if params[:commit] == "Create my proposal"
      if @project.save
        flash[:success] = "Project successfully proposed."
        redirect_to users_projects_path(year: @project.quarter.year,
                                        season: @project.quarter.season)
      else
        render 'new'
      end
    elsif params[:commit] == "Save as draft"
      @project.assign_attributes(status: "draft")
      if @project.save(validate: false)
        flash[:success] = "Proposal saved as a draft. You may edit it " +
          "by navigating to your \"my projects\" page."
        redirect_to users_projects_path(year: @project.quarter.year,
                                        season: @project.quarter.season)
      else
        render 'new'
      end
    end
  end

  def edit
  end

  # Not DRY (see #create and submissions_controller.rb), and a bit too much
  # logic.

  # ***
  # TODO: Check whether we should be checking the params instead in the
  # outermost `if` statement?
  # ***
  def update
    if @project.draft?
      # Editing the proposal while it's a draft
      @project.assign_attributes(project_params)

      if params[:commit] == "Create my proposal"
        @project.assign_attributes(status: "pending")
        if @project.save
          flash[:success] = "Proposal submitted."
          redirect_to users_projects_path(year: @project.quarter.year,
                                          season: @project.quarter.season)
        else
          render 'edit'
        end
      elsif params[:commit] == "Save as draft"
        if @project.save(validate: false)
          flash[:success] = "Proposal saved as a draft. You may edit it " +
            "by navigating to your \"my projects\" page."
          redirect_to users_projects_path(year: @project.quarter.year,
                                          season: @project.quarter.season)
        else
          render 'edit'
        end
      end

    else
      # Editing the proposal while it's pending
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
    # Something similar should be put in the application controller for every
    # page.
    if Quarter.count == 0
      flash[:error] = "There are no quarters. A quarter must exist before " +
        "you can view projects."
      redirect_to root_url and return
    end

    if params[:year] and params[:season]
      # We're visiting a quarter-specific projects page
      @quarter = Quarter.where(year: params[:year],
                               season: params[:season]).take
      # get the accepted published projects from this quarter
      @projects = Project.accepted_published_projects_in_quarter(@quarter)
    else
      # We're visiting the global projects page
      @projects = Project.current_accepted_published_projects

      # Filter the projects by quarter
      @projects = @projects.group_by(&:quarter).to_a.reverse

      # Get the quarters with future start_dates
      @future_quarters = Quarter.future_quarters
    end
  end

  def show
  end

  def pending
    if params[:year] and params[:season]
      @quarter = Quarter.where(year: params[:year],
                               season: params[:season]).take
      @projects = Project.unpublished_in_quarter(@quarter)
    else
      @projects = Project.current_unpublished_projects
    end
  end

  def update_status
    @db_project = Project.find(params[:id])

    # status_strings = {
    #   "Accept"             => { attr: "status", val: "accepted",
    #                             txt: "accepted" },
    #   "Request changes"    => { attr: "status", val: "pending",
    #                             txt: "set to \"pending\"" },
    #   "Reject"             => { attr: "status", val: "rejected",
    #                             txt: "rejected" },
    #   "Unpublish decision" => { attr: "status_published", val: false,
    #                             txt: "unpublished" },
    #   "Publish decision"   => { attr: "status_published", val: true,
    #                             txt: "published" }
    # }

    # changed_attrs = { "#{status_strings[params[:commit]][:attr]}" =>
    #                   status_strings[params[:commit]][:val] }

    # # Comments will be sent whenever they're present (for accept, reject,
    # # or request_changes).
    # if params[:project][:comments].present?
    #   changed_attrs[:comments] = params[:project][:comments]
    # end

    # if @db_project.update_attributes(changed_attrs)
    #   flash[:success] = "Project #{status_strings[params[:commit]][:txt]}."
    #   redirect_to @project
    # else
    #   flash.now[:error] = "Project could not be " +
    #     "#{status_strings[params[:commit]][:txt]}."
    #   render 'show'
    # end

    case params[:commit]

    when "Accept"
      if @db_project.update_attributes(status: "accepted")
        flash[:success] = "Project accepted."
        redirect_to view_context.q_path(@db_project)
      else
        flash.now[:error] = "Project could not be accepted."
        render 'show'
      end

    when "Request changes"
      # Note: the comments aren't persisted to the database.
      if @db_project.update_attributes(status: "pending",
                                       comments: params[:project][:comments])
        flash[:success] = "Changes requested and project status set to " +
          "\"pending\"."
        redirect_to view_context.q_path(@db_project)
      else
        flash.now[:error] = "Changes could not be requested and project " +
          "status could not be set to \"pending\"."
        render 'show'
      end

    when "Reject"
      if @db_project.update_attributes(status: "rejected")
        flash[:success] = "Project rejected."
        redirect_to view_context.q_path(@db_project)
      else
        flash.now[:error] = "Project could not be rejected."
        render 'show'
      end

    when "Unpublish decision"
      if @db_project.update_attributes(status_published: false)
        flash[:success] = "Project decision unpublished."
        redirect_to view_context.q_path(@db_project)
      else
        flash.now[:error] = "Project decision could not be unpublished."
        render 'show'
      end

    when "Publish decision"
      if @db_project.update_attributes(status_published: true)
        flash[:success] = "Project decision published."
        redirect_to view_context.q_path(@db_project)
      else
        flash.now[:error] = "Project decision could not be published."
        render 'show'
      end
    end
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
    @new_project.assign_attributes(quarter_id: Quarter.current_quarter.id,
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
    if current_user.admin?
      params.require(:project).permit(:name, :description, :status,
                                      :expected_deliverables, :prerequisites,
                                      :related_work, :comments, :cloned,
                                      :status_published, :advisor)
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

  def can_create_projects?
    if Quarter.active_exists? and !current_user.admin?
      before_deadline?("project_proposal", params[:year], params[:season])
    elsif !current_user.admin?
      redirect_to root_url, flash: { error: "This quarter is inactive." } and
        return
    end
  end

  def get_year_and_season
    @year   = params[:year]
    @season = params[:season]
  end

  def redirect_if_no_quarter_params
    if !params[:year] or !params[:season]
      flash[:error] = "You may only view pending projects in specific quarters."
      redirect_to root_path and return
    end
  end
end
