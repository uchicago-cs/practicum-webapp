class SubmissionsController < ApplicationController

  load_and_authorize_resource

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def index
    @submissions = Submission.all
  end

  def show
  end
end
