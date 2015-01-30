module ProjectPatterns

  def create_or_update_project(render_type)
    if params[:commit] == "Create my proposal"
      @project.assign_attributes(status: "pending") if render_type == :edit
      if @project.save
        flash[:success] = "Project successfully proposed."
        redirect_to users_projects_path(year: @project.quarter.year,
                                        season: @project.quarter.season)
      else
        render render_type
      end
    elsif params[:commit] == "Save as draft"
      @project.assign_attributes(status: "draft") if render_type == :new
      if @project.save(validate: false)
        flash[:success] = "Proposal saved as a draft. You may edit it " +
          "by navigating to your \"my projects\" page."
        redirect_to users_projects_path(year: @project.quarter.year,
                                        season: @project.quarter.season)
      else
        render render_type
      end
    end
  end

end
