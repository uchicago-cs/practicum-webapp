module ProjectPatterns

  def create_project_for_proposer
    proposing_user = params[:project][:proposer].downcase
    actual_user = (proposing_user.include? '@') ?
    User.find_by(email: proposing_user) :
      User.find_by(cnet: proposing_user)

    if actual_user
      @project = actual_user.projects.build(project_params)
      @project.proposer = proposing_user
      @project.assign_attributes(advisor: actual_user)
    else
      flash.now[:error] = "There is no user with that CNetID or E-mail " +
        "address."
      render 'new' and return
    end

    if !actual_user.advisor?
      flash.now[:error] = "That user is not an advisor."
      render 'new' and return
    end
  end

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
