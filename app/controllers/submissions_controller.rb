class SubmissionsController < ApplicationController

  load_and_authorize_resource

  before_action :get_project,                 only: [:index, :new, :create]
  before_action :project_accepted?,           only: [:new, :create]
  before_action :is_admin_or_advisor?,        only: :index
  before_action :already_applied_to_project?, only: [:new, :create]
  before_action :project_in_current_quarter?, only: [:new, :create]
  # before_actions on both new and create?

  def new
    @submission = Submission.new
  end

  def create
    @submission = @project.submissions.build(submission_params)
    @submission.assign_attributes(student_id: current_user.id)

    if @submission.save
      flash[:notice] = "Application submitted."
      redirect_to current_user
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
  end

  def accept
    if @submission.update_attributes(status: "accepted")
      flash[:notice] = "Application accepted."
      redirect_to submission_path
    else
      render 'show'
    end
  end

  def reject
    if @submission.update_attributes(status: "rejected")
      flash[:notice] = "Application rejected."
      redirect_to submission_path
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
      flash[:alert] = "This student did not upload a resume."
      render 'show'
    end
  end

  def update_status
    if @submission.update_attributes(submission_params)
      flash[:notice] = "Application status updated."
      redirect_to @submission
    else
      flash[:notice] = "Application status could not be updated."
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
    redirect_to(root_url, { alert: message }) unless @project.accepted?
  end

  def already_applied_to_project?
    message = "You have already applied to this project."
    redirect_to(root_url, { alert: message }) if \
      current_user.applied_to_project?(@project)
  end

  def project_in_current_quarter?
    message = "That project is no longer available."
    redirect_to(root_url, { alert: message }) unless \
      @project.quarter == Quarter.current_quarter
  end

  def is_admin_or_advisor?
    message = "Access denied."
    redirect_to(root_url, { alert: message }) unless \
      current_user.admin? or current_user.made_project?(@project)
  end

end
