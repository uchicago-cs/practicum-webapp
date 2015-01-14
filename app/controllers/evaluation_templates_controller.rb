class EvaluationTemplatesController < ApplicationController

  load_and_authorize_resource

  before_action :ensure_unique_question_positions, only: [:update,
                                                          :update_survey]
  before_action :get_quarter_of_template,          only: [:create, :show,
                                                          :add_question,
                                                          :update_basic_info,
                                                          :update_survey]
  before_action :get_formatted_quarters,           only: [:create, :show,
                                                          :new, :add_question,
                                                          :update_basic_info,
                                                          :update_survey]


  after_action(only: [:create, :update_basic_info]) { |c|
    c.edit_grade_question params[:evaluation_template][:has_grade] }

  # Ideally, use strong parameters throughout (just use template_params instead
  # of params).

  # NOTE: We use 'show' instead of 'edit'.

  def index
  end

  def show
  end

  def new
  end

  def create
    @evaluation_template = @quarter.evaluation_templates.
      build(evaluation_template_params)

    @evaluation_template.update_attributes(survey: {})
    if @evaluation_template.save
      flash[:success] = "Evaluation template successfully created."
      redirect_to evaluation_template_path(@evaluation_template)
    else
      flash.now[:error] = "Evaluation template was not successfully created."
      render 'new'
    end
  end

  # def edit
  # end

  # Not DRY. Maybe call model method based on what's in the params hash?
  def update_survey
    @evaluation_template.update_survey(params)
    if @evaluation_template.save
      flash[:success] = "Template updated."
      redirect_to @evaluation_template
    else
      flash.now[:error] = "Template could not be updated."
      render 'show'
    end
  end

  def update_basic_info
    @evaluation_template.update_basic_info(params)
    if @evaluation_template.save
      flash[:success] = "Template updated."
      redirect_to @evaluation_template
    else
      flash.now[:error] = "Template could not be updated."
      render 'show'
    end
  end

  def destroy
  end

  def add_question
    @evaluation_template.add_question(params)

    if @evaluation_template.save
      flash[:success] = "Question added to template."
      # Fix routes.rb re: this.
      redirect_to evaluation_template_path(@evaluation_template)
    else
      flash[:error] = "Question was unable to be added."
      render 'show'
    end
  end

  def update_question
    @evaluation_template.edit_question(params)

    if @evaluation_template.save
      flash[:success] = "Question updated."
      # Fix routes.rb re: this.
      redirect_to evaluation_template_path(@evaluation_template)
    else
      flash.now[:error] = "Question could not be updated."
      render 'show'
    end
  end


  # Ideally, move this logic from the controller to the model.
  def edit_grade_question(has_grade)
    # TODO: Replace this (radio button) with a select box.
    if params[:evaluation_template][:has_grade] == "1" and
        !@evaluation_template.has_grade_question?
      position = @evaluation_template.survey.length + 1
      survey_on_save = @evaluation_template.survey
      survey_on_save[position] =
                    { "question_type"      => "Radio button",
                      "question_prompt"    => "Grade",
                      "question_mandatory" => "1",
                      "question_options"   => { "1" => "A+",
                                                "2" => "A",
                                                "3" => "A-",
                                                "4" => "B+",
                                                "5" => "B",
                                                "6" => "B-",
                                                "7" => "C+",
                                                "8" => "C",
                                                "9" => "C-",
                                                "10" => "D+",
                                                "11" => "D",
                                                "12" => "D-" } }
      @evaluation_template.update_attributes(survey: survey_on_save)

    elsif params[:evaluation_template][:has_grade] == "0" and
        @evaluation_template.has_grade_question?
      @evaluation_template.survey.each do |k, q|
        if q["question_prompt"] == "Grade"
          @evaluation_template.survey.delete(k)
        end
      end
      # We need to edit and save the survey after we finish iterating over it.
      @evaluation_template.reorganize_questions_after_deletion
      @evaluation_template.save!
    end

  end

  private

  # Handle all params via template_params?
  def evaluation_template_params
    params.require(:evaluation_template).permit(:name, :quarter_id, :active,
                                                :has_grade, :start_date,
                                                :end_date)
  end

  def ensure_unique_question_positions
    if params[:ordering]
      message = "No two questions can have the same position."
      redirect_to evaluation_template_path, flash: { error: message } if
        params[:ordering].values.length != params[:ordering].values.uniq.length
    end
  end

  def get_quarter_of_template
    if params[:evaluation_template]
      # If we're in #create
      @quarter = Quarter.find(params[:evaluation_template][:quarter_id])
    else
      # If we're in #show or #add_question
      @quarter = @evaluation_template.quarter
    end
  end

  def get_formatted_quarters
    @quarters = Quarter.all.collect {
      |q| [view_context.fmt_quarter_show_current(q), q.id] }.reverse
  end
end
