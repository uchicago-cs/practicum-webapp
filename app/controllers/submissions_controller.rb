class SubmissionsController < ApplicationController

  load_and_authorize_resource

  before_action :get_project

  def new
    @submission = Submission.new
  end

  def create
    @submission = @project.submissions.build(submission_params)
    @submission.update_attributes(student_id: current_user.id)

    if @submission.save
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
    if @submission.update_attributes(accepted: true)
      flash[:notice] = "Application accepted."
      redirect_to project_submission_path      
    end
  end

  def reject
  end

  private

  def submission_params
    params.require(:submission).permit(:information, :student_id)
  end

  def get_project
    @project = Project.find(params[:project_id])
  end

end
