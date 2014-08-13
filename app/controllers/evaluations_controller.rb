class EvaluationsController < ApplicationController

  load_and_authorize_resource

  before_action :get_project_and_submission, only: [:new, :create, :index]
  before_action :already_evaluated?, only: [:new, :create]
  before_action :is_admin?, only: :index
  before_action :submission_status_sufficient?, only: [:new, :create]

  def index
  end

  def show
  end

  def new
    # @student = User.find(params[:student_id])
  end

  def create
    @evaluation = @submission.build_evaluation(evaluation_params)
    @evaluation.assign_attributes(student_id: @submission.student_id,
                                  project_id: @submission.project_id,
                                  advisor_id: @submission.project_advisor_id)
    if @evaluation.save
      flash[:success] = "Evaluation successfully submitted."
      redirect_to @evaluation, only_path: true
    else
      render 'new'
    end
  end

  private

  def evaluation_params
    params.require(:evaluation).permit(:submission_id, :student_id,
                                       :advisor_id, :project_id, :comments)
  end

  def get_project_and_submission
    @submission = Submission.find(params[:submission_id])
    @project = @submission.project
  end

  def already_evaluated?
    message = "You have already submitted an evaluation for this student."
    redirect_to(root_url, { error: message }) if \
      @project.advisor.evaluated_submission?(@submission)
  end

  def submission_status_sufficient?
    message = "Application status must be approved, published, and accepted."
    submission = Submission.find(params[:submission_id])
    redirect_to(root_url, { error: message }) unless \
      submission.accepted? and \
      submission.status_approved? and \
      submission.status_published?
  end
end
