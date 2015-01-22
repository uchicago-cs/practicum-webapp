class SubmissionsController < ApplicationController

  include SubmissionPatterns
  include ProjectSubmissionPatterns

  load_and_authorize_resource

  # before_actions on both new and create?
  before_action :get_project,                 only: [:index, :new, :create]
  before_action :submitted?,                  only: [:edit, :update]
  before_action :project_accepted?,           only: [:new, :create]
  before_action :is_admin_or_advisor?,        only: :index
  before_action :already_applied_to_project?, only: [:new, :create]
  before_action :project_in_current_quarter?, only: [:new, :create]
  before_action :get_statuses,                only: [:show, :update_status]
  before_action :project_accepted_and_pub?,   only: [:new, :create]
  before_action :can_create_submissions?,     only: [:new, :create, :update]
  before_action :get_year_and_season,         only: [:create, :update]
  before_action(except: [:index, :accepted]) { |c|
    c.get_this_user_for_object(@submission) }
  before_action(only: [:accept, :reject]) { |c|
    c.before_deadline?("advisor_decision") }
  before_action(only: :show) { |c|
    c.redirect_if_wrong_quarter_params(@submission) }

  def new
    @submission = Submission.new
  end

  def create

    # If an admin is creating the student's application, then
    # we figure out which student the admin is referring to.
    if params[:submission][:applicant].present?
      create_record_for_target_user :applicant
    else
      # Otherwise, build the submission normally.
      @submission = @project.submissions.build(submission_params)
      @submission.assign_attributes(student_id: current_user.id)
    end

    create_or_update_submission :new
  end


  def edit
  end

  def update
    # Note: students can only edit drafts.
    @submission.assign_attributes(submission_params)
  end

  def destroy
  end

  def index
    @submissions = Submission.all
  end

  def show
  end

  def accepted
    if params[:year] and params[:season]
      @quarter = Quarter.where(year: params[:year],
                               season: params[:season]).take
      # `@submissions` contains all accepted, approved, and published
      # submissions whose projects are in the given quarter.
      @submissions = Submission.accepted_approved_published_in_quarter(@quarter)
      @student_emails = User.where(id: @submissions.pluck(:student_id)).
        pluck(:email)
      @advisor_emails = User.where(id: @submissions.pluck(:advisor_id)).
        pluck(:email).uniq
    else
      @submissions = []
    end
  end

  def accept_or_reject
    @submission.update_attributes(comments: params[:submission][:comments])
    stat = { "Accept" => "accepted", "Reject" => "rejected" }[params[:commit]]

    if @submission.update_attributes(status: stat)
      flash[:success] = "Application #{stat}."
      redirect_to q_path(@submission)
    else
      render 'show'
    end
  end

  def download_resume
    if @submission.resume.exists? and authorized_to_download_resume?
      send_file(@submission.resume.path,
                type: @submission.resume.content_type,
                x_sendfile: true)
    else
      flash.now[:error] = "This student did not upload a resume."
      render 'show'
    end
  end

  def update_status
    @db_submission = Submission.find(params[:id])

    status_strings = {
      "Unapprove decision" => { attr: "status_approved", val: false,
                                txt: "unapproved" },
      "Approve changes"    => { attr: "status_approved", val: true,
                                txt: "approved" },
      "Unpublish decision" => { attr: "status_published", val: false,
                                txt: "unplished" },
      "Publish decision"   => { attr: "status_published", val: true,
                                txt: "published" } }

    save_status(@db_submission, @submission, status_strings)
  end

  private

  def submission_params
    as = [:information, :student_id, :status, :qualifications, :courses,
          :resume, :status_approved, :status_published, :comments]
    as << :applicant if current_user.admin?

    if current_user.admin? or current_user.advisor?
      params.require(:project).permit(*as)
    end
  end

  def get_project
    @project = Project.find(params[:project_id])
  end

  def project_accepted?
    message = "Access denied."
    redirect_to root_url, flash: { error: message } unless @project.accepted?
  end

  def already_applied_to_project?
    message = "You have already applied to this project."
    redirect_to root_url, flash: { error: message } if
      current_user.applied_to_project?(@project) and !current_user.admin?
  end

  def project_in_current_quarter?
    message = "That project was offered in a previous quarter and is no " +
      "longer available."
    redirect_to root_url, flash: { error: message } unless
      @project.quarter == Quarter.current_quarter
  end

  def is_admin_or_advisor?
    message = "Access denied."
    redirect_to root_url, flash: { error: message } unless
      current_user.admin? or current_user.made_project?(@project)
  end

  def get_statuses
    @status_approved  = @submission.status_approved
    @status_published = @submission.status_published
  end

  def project_accepted_and_pub?
    message = "Access denied."
    redirect_to root_url, flash: { error: message } unless
      (@project.status == "accepted" and @project.status_published?)
  end

  def authorized_to_download_resume?
    current_user and (current_user.admin? or
                      current_user.made_project?(@submission.project))
  end

  def submitted?
    message = "You cannot edit a submitted application."
    redirect_to root_url, flash: { error: message } unless @submission.draft?
  end

  def can_create_submissions?
    unless current_user.admin?
      before_deadline?("student_submission")
    end
  end
end
