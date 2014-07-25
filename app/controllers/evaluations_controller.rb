class EvaluationsController < ApplicationController

  load_and_authorize_resource

  before_action :get_project_and_submission
  before_action :already_evaluated?, only: [:new, :create]
  before_action :is_admin?, only: :index

  def index
  end

  def show
  end

  def new
    # @student = User.find(params[:student_id])
  end

  def create
    @evaluation = @submission.build_evaluation(evaluation_params)
    @evaluation.update_attributes(student_id: @submission.student_id,
                                  project_id: @submission.project_id,
                                  advisor_id: @submission.project_advisor_id)
    if @evaluation.save
      flash[:notice] = "Evaluation successfully submitted."
      redirect_to [@project, @submission, @evaluation]
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
    @project = Project.find(params[:project_id])
  end

  def already_evaluated?
    # Messy -- refactor this.
    advisor = Project.find(params[:project_id]).advisor

    message = "You have already submitted an evaluation for this student."
    redirect_to(root_url, { notice: message }) if \
      advisor.evaluated_submission?(@submission)
  end
end