module SubmissionsHelper

  def formatted_status_for_advisor(submission)
    message="#{submission.status.capitalize} (pending administrator approval)"
    (!submission.status_approved and !submission.pending?) ?
      message : submission.status.capitalize
  end

  def formatted_status_for_student(submission)
    submission.status_published ? submission.status.capitalize : "Pending"
  end

  def formatted_status(submission)
    # Might be confusing if the user applied to his / her own project.
    # (Should we disallow that?)
    if current_user.made_submission?(submission)
      formatted_status_for_student(submission)
    elsif current_user.made_project?(submission.project) or current_user.admin?
      formatted_status_for_advisor(submission)
    end
  end

  def formatted_status_approved?(submission)
    submission.status_approved? ? "Yes" : "No"
  end

  def formatted_status_published?(submission)
    submission.status_published? ? "Yes" : "No"
  end

end
