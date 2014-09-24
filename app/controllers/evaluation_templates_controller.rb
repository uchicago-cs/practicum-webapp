class EvaluationTemplatesController < ApplicationController

  load_and_authorize_resource

  before_action :ensure_unique_question_positions, only: :update
  before_action :get_quarter_of_template,          only: [:create, :show]
  before_action :get_formatted_quarters,           only: [:new, :show]

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

  private

  # Handle all params via template_params?
  def evaluation_template_params
    params.require(:evaluation_template).permit(:name, :quarter_id, :active)
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
      # If we're in #show
      @quarter = @evaluation_template.quarter
    end
  end

  def get_formatted_quarters
    @quarters = Quarter.all.collect {
      |q| [view_context.fmt_quarter_show_current(q), q.id] }.reverse
  end
end
