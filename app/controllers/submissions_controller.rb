class SubmissionsController < ApplicationController

  load_and_authorize_resource

  before_action :get_project
  before_action :project_accepted?, only: :new
  before_action :is_admin_or_advisor?, only: :index

  def new
    @submission = Submission.new
  end

  def create
    @submission = @project.submissions.build(submission_params)
    @submission.update_attributes(student_id: current_user.id)

    if @submission.save
      Notifier.student_applied(@project.advisor, 
                               current_user).deliver
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
    end
  end

  def reject
  end

  private

  def submission_params
    params.require(:submission).permit(:information, :student_id, :status,
                                       :qualifications, :courses)
  end

  def get_project
    @project = Project.find(params[:project_id])
  end

  def project_accepted?
    redirect_to root_url unless @project.accepted?
  end

  def is_admin_or_advisor?
    redirect_to root_url unless current_user.admin? or current_user.advisor?
  end

end
