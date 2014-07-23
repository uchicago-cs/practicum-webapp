class EvaluationsController < ApplicationController

  load_and_authorize_resource

  before_action :get_submission
  before_action :get_evaluator, only: :index
  before_action :already_evaluated_student?, only: [:new, :create]
  before_action :is_admin?, only: :index

  def index
  end

  def show
  end

  def new
    # @student = User.find(params[:student_id])
  end

  def create
    @evaluation = current_user.evaluations.build(evaluation_params)
    @evaluation.update_attributes(student_id: params[:student_id],
                                  project_id: params[:project_id])
    if @evaluation.save
      User.admins.each do |admin|
        Notifier.evaluation_submitted(current_user, admin).deliver
      end

      flash[:notice] = "Evaluation successfully submitted."
      redirect_to @evaluation
    else
      render 'new'
    end
  end

  private

  def evaluation_params
    params.require(:evaluation).permit(:student_id, :advisor_id, :project_id,
                                       :comments)
  end

  def get_submission

  end

  def get_evaluator
    #@evaluator = User.find(params[:id])
  end

  def already_evaluated_student?
    #redirect_to root_url if @evaluator.evaluated_submission?(@submission)
  end
end
