class SubmissionsController < ApplicationController

  load_and_authorize_resource

  before_action :get_project
  before_action :project_accepted?, only: :new
  before_action :is_admin_or_advisor?, only: :index
  before_action :already_applied_to_project?, only: :new
  before_action :right_project?, only: [:show, :edit, :update]
  
  # Getting a bit thick here -- slim it down

  def new
    @submission = Submission.new
  end

  def create
    @submission = @project.submissions.build(submission_params)
    @submission.update_attributes(student_id: current_user.id)

    if @submission.save
      Notifier.student_applied(@project.advisor, 
                               current_user).deliver
      User.admins.each do |admin|
        Notifier.student_applied(admin, current_user).deliver
      end
      flash[:notice] = "Application submitted!"
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
      Notifier.accept_student(@submission.student,
                              @submission.project).deliver
      flash[:notice] = "Application accepted."
      redirect_to project_submission_path
    else
      render 'show'
    end
  end

  def reject
    if @submission.update_attributes(status: "rejected")
      Notifier.reject_student(@submission.student,
                              @submission.project).deliver
      flash[:notice] = "Application rejected."
      redirect_to project_submission_path   
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
      flash[:notice] = "This student did not upload a resume."
      render 'show'
    end
  end

  private

  def submission_params
    params.require(:submission).permit(:information, :student_id, :status,
                                       :qualifications, :courses, :resume)
  end

  def get_project
    @project = Project.find(params[:project_id])
  end

  # Add flashes before these redirects?

  def project_accepted?
    redirect_to root_url unless @project.accepted?
  end

  def is_admin_or_advisor?
    redirect_to root_url unless current_user.admin? or current_user.advisor?
  end

  def already_applied_to_project?
    redirect_to root_url if current_user.applied_to_project?(@project)
  end

  def right_project?
    redirect_to root_url unless \
      params[:project_id].to_i == @submission.project_id
  end

end
