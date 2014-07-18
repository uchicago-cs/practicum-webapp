class MessagesController < ApplicationController

  load_and_authorize_resource
  
  # A bit sloppy

  def new
    @project = Project.find(params[:id])    
    @message = Message.new
    flash[:project_id] = @project.id
    # Could this var conflict with any others?
  end

  def create
    @project = Project.find(flash[:project_id])
    @message = Message.new(message_params)
    
    @message.attributes = { sender: current_user.email,
      recipient: @project.advisor_email }
    if @message.save
      # NOTE: Right now, this saves the message to the database.
      # See http://guides.rubyonrails.org/
      # form_helpers.html#dealing-with-basic-forms
      # for a possible way to implement message functionality without using
      # a model and a database table.
      # (In that case, use `if @message.valid?`.)
      Notifier.project_needs_edits(@project.advisor,
                                   @project).deliver
      flash[:notice] = "Successfully sent revision request."
      redirect_to @project
    else
      render 'new'
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :sender, :recipient)
  end

end
