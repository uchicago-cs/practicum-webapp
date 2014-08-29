class EvaluationsController < ApplicationController

  load_and_authorize_resource

  before_action :get_project_and_submission,    only: [:new, :create]
  before_action :already_evaluated?,            only: [:new, :create]
  before_action :is_admin?,                     only: :index
  before_action :submission_status_sufficient?, only: [:new, :create]
  before_action :prevent_dup_positions,         only: :update_template
  before_action :get_template

  def index
  end

  def edit_template
  end

  def update_template
    delete = false
    params[:delete].each do |question_num, should_be_removed|
      if (should_be_removed == "1" ? true : false)
        @template.survey.reject! { |key| key == question_num.to_i }
        delete = true
      end
      # Put the above into its own method in evaluation_survey.rb, and
      # have it return `delete`
    end

    @template.reorganize_questions_after_deletion
    @template.change_mandatory(params[:mandatory]) unless delete
    @template.change_order(params[:ordering])      unless delete

    if @template.save
      flash[:success] = "Template updated."
      redirect_to edit_evaluation_template_path
    else
      flash.now[:error] = "Template could not be updated."
      render 'edit_template'
    end
  end

  def update_template_question
    # We probably don't want to pass the entire params hash.
    @template.edit_question(params)

    if @template.save
      flash[:success] = "Question updated."
      redirect_to edit_evaluation_template_path
    else
      flash.now[:error] = "Question could not be updated."
      render 'edit_template'
    end
  end

  def add_to_template
    if EvaluationTemplate.any?

      num = @template.survey.length + 1
      # Just append to @template.survey[num](["question_options"]?) or merge
      # if this is true?
      if params[:question_type] == "Radio button"
        # Will this be chosen for all selections and not just "Radio button"?
        @template.survey[num] = {
          "question_type"      => params[:question_type],
          "question_prompt"    => params[:question_prompt],
          "question_mandatory" => params[:question_mandatory],
          "question_options"   => params[:radio_button_options]
        }
      else
        @template.survey[num] = {
          "question_type"      => params[:question_type],
          "question_prompt"    => params[:question_prompt],
          "question_mandatory" => params[:question_mandatory]
        }
      end

    else
      # Also remove the if-else statement here.
      if params[:radio_button_options].present?
        @template.survey = {
          1 => { "question_type"      => params[:question_type],
                 "question_prompt"    => params[:question_prompt],
                 "question_mandatory" => params[:question_mandatory],
                 "question_options"   => params[:radio_button_options] }
        }
      else
        @template.survey = {
          1 => { "question_type"      => params[:question_type],
                 "question_prompt"    => params[:question_prompt],
                 "question_mandatory" => params[:question_mandatory] }
        }
      end

    end

    if @template.save
      flash[:success] = "Question added to template."
      redirect_to edit_evaluation_template_path
    else
      flash[:error] = "Question was unable to be added."
      render 'edit_template'
    end

  end

  def show
  end

  def new
    # @student = User.find(params[:student_id])
  end

  def create
    @evaluation = @submission.build_evaluation
    @evaluation.assign_attributes(student_id: @submission.student_id,
                                  project_id: @submission.project_id,
                                  advisor_id: @submission.project_advisor_id)
    @evaluation.set_survey(params[:survey])

    if @evaluation.save
      flash[:success] = "Evaluation successfully submitted."
      redirect_to @evaluation, only_path: true
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
    @template = EvaluationTemplate.first || EvaluationTemplate.new
  end

  def prevent_dup_positions
    message = "No two questions can have the same position."
    redirect_to edit_evaluation_template_path, flash: { error: message } if
      params[:ordering].values.length != params[:ordering].values.uniq.length
  end
end
