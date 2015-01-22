module ProjectSubmissionPatterns

  # Allows an admin to create either a proposal or a submission for a target
  # user (either a proposer (advisor) or applicant (student)).
  def create_record_for_target_user(user_type)
    target_user = params[:project][user_type].downcase
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

end
