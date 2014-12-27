class EvaluationsController < ApplicationController

  load_and_authorize_resource

  before_action :get_project_and_submission,    only: [:new, :create]
  before_action :already_evaluated?,            only: [:new, :create]
  before_action :is_admin?,                     only: :index
  before_action :submission_status_sufficient?, only: [:new, :create]
  before_action :get_template
  before_action :get_student,                   only: [:new, :create]
  before_action(only: :show) { |c|
    c.redirect_if_wrong_quarter_params(@evaluation) }

  def index
    # TODO: DRY up (see ProjectsController#index)
    if Quarter.count == 0
      flash[:error] = "There are no quarters. A quarter must exist before " +
        "you can view evaluations."
      redirect_to root_url and return
    end

    if params[:year] and params[:season]
      @quarter = Quarter.where(year: params[:year],
                               season: params[:season]).take
      @evaluations = Evaluation.in_quarter(@quarter)
    else
      flash[:error] = "You must view evaluations in a quarter."
      redirect_to root_url and return
    end
  end

  def show
  end

  def new
  end

  def create
    @evaluation = @submission.evaluations.build
    @evaluation.assign_attributes(evaluation_template_id:
                                  EvaluationTemplate.current_active.id)
    @evaluation.set_attributes_on_create(params)

    if @evaluation.save
      flash[:success] = "Evaluation successfully submitted."
      # We use `evaluation_path(@evaluation)` instead of simply `@evaluation`
      # as per the Brakeman redirect warning.
      redirect_to q_path(@evaluation)
    else
      flash.now[:error] = "Evaluation was not submitted."
      render 'new'
    end
  end

  private

  def get_project_and_submission
    @submission = Submission.find(params[:submission_id])
    @project = @submission.project
  end

  def already_evaluated?
    # TODO:
    # This filter should redirect the advisor only if the advisor has already
    # made an evaluation of that particular type (is it possible to determine
    # this from here?).

    message = "You have already submitted an evaluation for this student."
    redirect_to root_url, flash: { error: message } if
      @project.advisor.completed_active_evaluation?(@submission)
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
    @template = EvaluationTemplate.current_active
  end

  def get_student
    @student = Submission.find(params[:submission_id]).student
  end
end
