class EvaluationTemplatesController < ApplicationController
  load_and_authorize_resource

  before_action :ensure_unique_question_positions, only: :update

  # Ideally, use strong parameters throughout (just use template_params instead
  # of params).

  # NOTE: We use 'show' in place of 'edit'.

  def index
  end

  def show
  end

  def new
  end

  def create
  end

  # def edit
  # end

  def update
    @evaluation_template.update_survey(params)
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

  def template_params

  end

  def ensure_unique_question_positions
    message = "No two questions can have the same position."
    redirect_to evaluation_template_path, flash: { error: message } if
      params[:ordering].values.length != params[:ordering].values.uniq.length
  end
end
