module ProjectSubmissionPatterns

  # Allows an admin to create either a proposal or a submission for a target
  # user (either a proposer (advisor) or applicant (student)).
  def create_record_for_target_user(user_type)
    record_type = (user_type == :proposer) ? :project : :submission
    target_user = params[record_type][user_type].downcase
    attr_type = (target_user.include? '@') ? :email : :cnet
    actual_user = User.find_by(attr_type => target_user)

    if actual_user
      # TODO: move to model
      if user_type == :proposer
        @project = actual_user.projects.build(project_params)
        @project.assign_attributes(proposer: target_user, advisor: actual_user)
      elsif user_type == :applicant
        @submission = @project.submissions.build(submission_params)
        @submission.applicant = target_user # Needed for the validation proc
        @submission.assign_attributes(student_id: actual_user.id)
      end
    else
      flash.now[:error] = "There is no user with that CNetID or E-mail " +
        "address."
      render 'new' and return
    end

    f = (user_type == :proposer) ? :advisor? : :student?
    role = (user_type == :proposer) ? "an advisor" : "a student"

    if !actual_user.send(f)
      flash.now[:error] = "That user is not #{role}."
      render 'new' and return
    end
  end

  def save_status(db_record, record, s_info)
    changed_attrs = { "#{s_info[params[:commit]][:attr]}" =>
      s_info[params[:commit]][:val] }

    rec_obj = (db_record.class == Project) ? "Project" : "Application decision"

    if db_record.class == Project
      # Comments will be sent whenever they're present (for accept, reject,
      # or request_changes, and only for projects).
      if params[:project] and params[:project][:comments].present?
        changed_attrs[:comments] = params[:project][:comments]
      end
    end

    if db_record.update_attributes(changed_attrs)
      flash[:success] = "#{rec_obj} #{s_info[params[:commit]][:txt]}."
      redirect_to view_context.q_path(record)
      # TODO: Why do we need `view_context` here but not in other controllers?
    else
      flash.now[:error] = "#{rec_obj} could not be " +
        "#{s_info[params[:commit]][:txt]}."
      render 'show'
    end
  end

end
