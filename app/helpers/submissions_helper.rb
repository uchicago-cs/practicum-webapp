module SubmissionsHelper

  # Ideally, find a different way to solve this...
  def db_submission(submission)
    Submission.find(submission.id)
  end

  def advisor_feedback(submission)
    submission.comments.present? ? submission.comments : "N/A"
  end

  def submit_submission_confirmation
    "Are you sure you want to submit your application? Once you submit your " +
      "application, you will be unable to modify it."
  end

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

  # Clean this up...
  def formatted_status_for_advisor(submission)
    msg="#{submission.status.capitalize} (pending administrator approval)"

    if submission.status_approved and !submission.status_published
      "#{submission.status.capitalize} (student not yet notified)"
    elsif submission.status_approved and submission.status_published
      "#{submission.status.capitalize} (student notified)"
    else
      (!submission.status_approved and
       (!submission.pending? and !submission.draft?)) ?
       msg : submission.status.capitalize
    end
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
