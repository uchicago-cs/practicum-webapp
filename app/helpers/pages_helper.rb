module PagesHelper

  # Not DRY.
  # Determine table row class for users.
  def advisor_project_row_class(project)
    if project.status_published?
      status_classes = { "accepted" => "success", "rejected" => "danger",
        "pending" => "" }
      status_classes[project.status]
    else
      status_classes = { "accepted" => "info", "rejected" => "info",
        "pending" => "" }
      status_classes[project.status]
    end
  end

  def advisor_submission_row_class(submission)
    if submission.status_approved? and submission.status_published?
      status_classes = { "accepted" => "success", "rejected" => "danger",
                       "pending" => "" }
      status_classes[status]
    end
  end

end
