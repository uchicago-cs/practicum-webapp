module SubmissionsHelper

  # Shows resume info if student uploaded a resume.
  def formatted_resume_info(submission)
    if submission.resume.exists?
      link_to(submission.resume_file_name,
              download_resume_path(submission.id)) +
      " (#{number_to_human_size(submission.resume_file_size)})"
    else
      "No resume uploaded"
    end
  end

  def formatted_status_for_advisor(submission)
    message="#{submission.status.capitalize} (pending administrator approval)"
    (!submission.status_approved and !submission.pending?) ?
      message : submission.status.capitalize
  end

  def formatted_status_for_student(submission)
    if submission.status != "draft"
      submission.status_published ? submission.status.capitalize : "Pending"
    elsif submission.status == "draft"
      "Draft (unsubmitted)"
    end
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
