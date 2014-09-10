class SubmissionsController < ApplicationController

  load_and_authorize_resource

  # before_actions on both new and create?
  before_action :get_project,                 only: [:index, :new, :create]
  before_action :project_accepted?,           only: [:new, :create]
  before_action :is_admin_or_advisor?,        only: :index
  before_action :already_applied_to_project?, only: [:new, :create]
  before_action :project_in_current_quarter?, only: [:new, :create]
  before_action :get_statuses,                only: [:show, :update_status]
  before_action :project_accepted_and_pub?,   only: [:new, :create]
  before_action(except: :index) { |c|
    c.get_this_user_for_object(@submission) }
  before_action(only: [:new, :create]) { |c|
    c.before_deadline?("student_submission") }
  before_action(only: [:accept, :reject]) { |c|
    c.before_deadline?("advisor_decision") }

  def new
    @submission = Submission.new
  end

  def create
    @submission = @project.submissions.build(submission_params)
    @submission.assign_attributes(student_id: current_user.id)

    if @submission.save
      flash[:success] = "Application submitted."
      redirect_to users_submissions_path(current_user)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def index
    @submissions = Submission.all
  end

  def show
    @submission_status_sufficient = @submission.status_sufficient?
  end

  def accept
    if @submission.update_attributes(status: "accepted")
      flash[:success] = "Application accepted."
      redirect_to @submission
    else
      render 'show'
    end
  end

  def reject
    if @submission.update_attributes(status: "rejected")
      flash[:success] = "Application rejected."
      redirect_to @submission
    else
      render 'show'
    end
  end

  def download_resume
    if @submission.resume.exists?
      send_file(@submission.resume.path,
                type: @submission.resume.content_type,
                x_sendfile: true)
    else
      flash.now[:error] = "This student did not upload a resume."
      render 'show'
    end
  end

  def update_status
    if @submission.update_attributes(submission_params)
      flash[:success] = "Application status updated."
      redirect_to @submission
    else
      flash.now[:error] = "Application status could not be updated."
      render 'show'
    end
  end

  private

  def submission_params
    params.require(:submission).permit(:information, :student_id, :status,
                                       :qualifications, :courses, :resume,
                                       :status_approved, :status_published)
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
      current_user.applied_to_project?(@project)
  end

  def project_in_current_quarter?
    message = "That project is no longer available."
    redirect_to root_url, flash: { error: message } unless
      @project.quarter == Quarter.current_quarter
  end

  def is_admin_or_advisor?
    message = "Access denied."
    redirect_to root_url, flash: { error: message } unless
      current_user.admin? or current_user.made_project?(@project)
  end

  def get_statuses
    @status_approved = @submission.status_approved
    @status_published = @submission.status_published
  end

  def project_accepted_and_pub?
    message = "Access denied."
    redirect_to root_url, flash: { error: message } unless
      (@project.status == "accepted" and @project.status_published?)
  end

end
