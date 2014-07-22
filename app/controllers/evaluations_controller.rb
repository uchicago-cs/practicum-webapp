class EvaluationsController < ApplicationController

  load_and_authorize_resource

  def show
  end

  def new
    #@student = User.find(params[:student_id])
    @student = params[:student_id]
    @user = User.find(params[:student_id])
  end

  def create
    @evaluation.update_attributes(student_id: params[:student_id],
                                  project_id: params[:project_id])
    @evaluation = current_user.evaluations.build(evaluation_params)
    if @evaluation.save
      User.admins.each do |admin|
        Notifier.evaluation_submitted(admin).deliver
      end

      flash[:notice] = "Evaluation successfully submitted."
      redirect_to :new_evaluation_path
    else
      render 'new'
    end
  end

  private

  def evaluation_params
    params.require(:evaluation).permit(:student_id, :advisor_id, :project_id,
                                       :comments)
  end
end
