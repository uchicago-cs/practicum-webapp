class SubmissionsController < ApplicationController

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
  before_action(except: :index) { |c|
    c.get_this_user_for_object(@submission) }
  before_action(only: [:new, :create, :update]) { |c|
    c.before_deadline?("student_submission") }
  before_action(only: [:accept, :reject]) { |c|
    c.before_deadline?("advisor_decision") }

  def new
    @submission = Submission.new
  end

  def create
    @submission = @project.submissions.build(submission_params)
    @submission.assign_attributes(student_id: current_user.id)

    # Could be DRYer, but be careful to not rely on whether params[:commit]
    # is one of the strings _or not_; we should check whether it is one of the
    # strings _or the other_. (?)
    if params[:commit] == "Submit my application"
      if @submission.save
        flash[:success] = "Application submitted."
        redirect_to users_submissions_path(current_user)
      else
        render 'new'
      end
    elsif params[:commit] == "Save as draft"
      @submission.assign_attributes(status: "draft")
      if @submission.save(validate: false)
        flash[:success] = "Application saved as a draft. You may edit it " +
          "by navigating to your \"my applications\" page."
        redirect_to users_submissions_path(current_user)
      else
        render 'new'
      end
    end
  end


  def edit
  end

  # Not DRY. (See #create.)
  # Students can only edit drafts, i.e., submissions where status == "draft".
  def update
    @submission.assign_attributes(submission_params)

    if params[:commit] == "Submit my application"
      @submission.assign_attributes(status: "pending")
      if @submission.save
        flash[:success] = "Application submitted."
        redirect_to users_submissions_path(current_user)
      else
        render 'edit'
      end
    elsif params[:commit] == "Save as draft"
      if @submission.save(validate: false)
        flash[:success] = "Application saved as a draft. You may edit it " +
          "by navigating to your \"my applications\" page."
        redirect_to users_submissions_path(current_user)
      else
        render 'edit'
      end
    end
  end

  def destroy
  end

  def index
    @submissions = Submission.all
  end

  def show
  end

  def accept_or_reject
    @submission.update_attributes(comments: params[:submission][:comments])

    if params[:commit] == "Accept"
      if @submission.update_attributes(status: "accepted")
        flash[:success] = "Application accepted."
        redirect_to @submission
      else
        render 'show'
      end
    elsif params[:commit] == "Reject"
      if @submission.update_attributes(status: "rejected")
        flash[:success] = "Application rejected."
        redirect_to @submission
      else
        render 'show'
      end
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

  # Not DRY.
  def update_status
    @db_submission = Submission.find(params[:id])

    case params[:commit]

    when "Unapprove decision"
      if @db_submission.update_attributes(status_approved: false)
        flash[:success] = "Application decision unapproved."
        redirect_to @submission
      else
        flash.now[:error] = "Application decision could not be unapproved."
        render 'show'
      end

    when "Approve decision"
      if @db_submission.update_attributes(status_approved: true)
        flash[:success] = "Application decision approved."
        redirect_to @submission
      else
        flash.now[:error] = "Application decision could not be approved."
        render 'show'
      end

    when "Unpublish decision"
      if @db_submission.update_attributes(status_published: false)
        flash[:success] = "Application decision unpublished."
        redirect_to @submission
      else
        flash.now[:error] = "Application decision could not be unpublished."
        render 'show'
      end

    when "Publish decision"
      if @db_submission.update_attributes(status_published: true)
        flash[:success] = "Application decision published."
        redirect_to @submission
      else
        flash.now[:error] = "Application decision could not be published."
        render 'show'
      end
    end
  end

  private

  def submission_params
    params.require(:submission).permit(:information, :student_id, :status,
                                       :qualifications, :courses, :resume,
                                       :status_approved, :status_published,
                                       :comments)
  end

  def get_project
    @project = Project.find(params[:project_id])#params[:project_id] ?
      #Project.find(params[:project_id]) : @submission.project
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
end
