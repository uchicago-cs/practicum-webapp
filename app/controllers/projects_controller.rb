class ProjectsController < ApplicationController

  load_and_authorize_resource
  # Load the resource the viewer is trying to view and authorize
  # based on the viewer's role (and whether the viewer is logged in.)

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
    # @projects = Project.where.not(id: current_user.projects_applied_to)
  end

  def show
  end
end
