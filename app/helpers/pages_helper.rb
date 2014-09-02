module PagesHelper

  def alert_type_by_deadline
    before_deadline?("admin_publish") ? "info" : "warning"
  end

  def status_classes
    { "accepted" => "success", "rejected" => "danger", "pending" => "" }
  end

  # Determine table row class for users.
  def advisor_project_row_class(project)
    if project.status_published?
      status_classes[project.status]
    else
      if project.status == "accepted" or project.status == "rejected"
        "info"
      else
        ""
      end
    end
  end

  def advisor_submission_row_class(submission)
    if submission.status_approved? and submission.status_published?
      status_classes[submission.status]
    end
  end

end
