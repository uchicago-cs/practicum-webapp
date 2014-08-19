class EvaluationsController < ApplicationController

  load_and_authorize_resource

  before_action :get_project_and_submission, only: [:new, :create]
  before_action :already_evaluated?, only: [:new, :create]
  before_action :is_admin?, only: :index
  before_action :submission_status_sufficient?, only: [:new, :create]

  def index
  end

  def show
  end

  def new
    @evaluation_answers = []
    EvaluationQuestion.active.each do |question|
      EvaluationQuestionEvaluationJoin.new(evaluation: @evaluation,
                                           evaluation_question: question)
      @evaluation_answers <<
        question.evaluation_answers.build(evaluation: @evaluation)

    end
  end

  def create
    @evaluation = @submission.build_evaluation
    @evaluation.assign_attributes(student_id: @submission.student_id,
                                  project_id: @submission.project_id,
                                  advisor_id: @submission.project_advisor_id)
    if @evaluation.save

      EvaluationQuestion.active.each_with_index do |question, index|
        EvaluationQuestionEvaluationJoin.create(evaluation: @evaluation,
                                                evaluation_question: question)

        @evaluation_answer =
          question.
          evaluation_answers.
          build(response: params[:evaluation_answers] \
                [:evaluation_answer][index.to_s][:response])
        @evaluation_answer.evaluation = @evaluation
        @evaluation_answer.save
      end

      flash[:success] = "Evaluation successfully submitted."
      redirect_to @evaluation
    else
      render 'new'
    end
  end

  def edit_template
    @evaluation_questions = EvaluationQuestion.where(active: true)
    @evaluation_question = EvaluationQuestion.new
  end

  def update_template
  end

  def add_question_to_template
    @evaluation_question = EvaluationQuestion.new(evaluation_question_params)
    if @evaluation_question.save
      flash[:success] = "Question successfully added."
      redirect_to evaluation_template_edit_path
    else
      render 'edit_template'
    end
  end

  private

  # def evaluation_params
  #   params.require(:evaluation).permit(:submission_id, :student_id,
  #                                      :advisor_id, :project_id, :comments,
  #                                      :evaluation_answer,
  #                                      {evaluation_answers_attributes:
  #                                      [:response]},
  #                                      :evaluation_questions)
  # end

  def evaluation_question_params
    params.require(:evaluation_question).permit(:question_type, :prompt,
                                                :active)
  end

  def evaluation_answer_params
    params.require(:evaluation_answers).
      permit(:evaluation_answer => [:response])
  end

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
end
