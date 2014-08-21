class EvaluationsController < ApplicationController

  load_and_authorize_resource

  before_action :get_project_and_submission,    only: [:new, :create]
  before_action :already_evaluated?,            only: [:new, :create]
  before_action :is_admin?,                     only: :index
  before_action :submission_status_sufficient?, only: [:new, :create]
  before_action :get_template,                  only: [:index, :edit_template,
                                                       :update_template]

  def index
  end

  def edit_template
  end

  def update_template
    if EvaluationSurvey.any?

      num = @template.survey.length + 1
      logger.debug @template.survey
      @template.survey[num] = {
        "question_type" => params[:question_type],
        "question_prompt" => params[:question_prompt]
      }

    else

      @template.survey = {
        1 => { "question_type" => params[:question_type],
          "question_prompt" => params[:question_prompt] }
      }

    end

    if @template.save
      flash[:success] = "Template updated."
      redirect_to edit_evaluation_template_path
    else
      flash.now[:error] = "Template was unable to be updated."
      render 'edit_template'
    end

  end

  def show
  end

  def new
    # @student = User.find(params[:student_id])
  end

  def create
    @evaluation = @submission.build_evaluation#(evaluation_params)
    @evaluation.assign_attributes(student_id: @submission.student_id,
                                  project_id: @submission.project_id,
                                  advisor_id: @submission.project_advisor_id)
    @evaluation.survey = "{}"
    if @evaluation.save
      flash[:success] = "Evaluation successfully submitted."
      redirect_to @evaluation, only_path: true
    else
      render 'new'
    end
  end

  private

  # def evaluation_params
  #   params.require(:evaluation).permit(:submission_id, :student_id,
  #                                      :advisor_id, :project_id)
  # end

  def get_project_and_submission
    @submission = Submission.find(params[:submission_id])
    @project = @submission.project
  end

  def already_evaluated?
    message = "You have already submitted an evaluation for this student."
    redirect_to root_url, flash: { error: message } if
      @project.advisor.evaluated_submission?(@submission)
  end

  def submission_status_sufficient?
    message = "Application status must be approved, published, and accepted."
    submission = Submission.find(params[:submission_id])
    redirect_to root_url, flash: { error: message } unless
      submission.accepted? and
      submission.status_approved? and
      submission.status_published?
  end

  def get_template
    # There should be only one evaluation_survey in the table.
    @template = EvaluationSurvey.first || EvaluationSurvey.new
  end
end
