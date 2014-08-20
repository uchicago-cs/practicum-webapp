module ApplicationHelper

  def flash_class(flash_type)
    case flash_type
    when :notice  then "info"
    when :success then "success"
    when :error   then "danger"
    when :alert   then "warning"
    else               flash_type
    end
  end

  # Determine table row class for admins.
  def row_class(status)
    # Creating this hash on each call... Consider revising.
    status_classes = { "accepted" => "success", "rejected" => "danger",
                       "pending" => "" }
    status_classes[status]
  end

  # Refactor these four into one method.
  def project_proposal_deadline
    Quarter.current_quarter.project_proposal_deadline.
      strftime("%I:%M %p on %D (%A, %B %d, %Y)")
  end

  def student_submission_deadline
    Quarter.current_quarter.student_submission_deadline.
      strftime("%I:%M %p on %D (%A, %B %d, %Y)")
  end

  def advisor_decision_deadline
    Quarter.current_quarter.advisor_decision_deadline.
      strftime("%I:%M %p on %D (%A, %B %d, %Y)")
  end

  def admin_publish_deadline
    Quarter.current_quarter.admin_publish_deadline.
      strftime("%I:%M %p on %D (%A, %B %d, %Y)")
  end

  # Refactor these three into one method.
  def before_proposal_deadline?
    DateTime.now <= Quarter.current_quarter.project_proposal_deadline
  end

  def before_submission_deadline?
    DateTime.now <= Quarter.current_quarter.student_submission_deadline
  end

  def before_decision_deadline?
    DateTime.now <= Quarter.current_quarter.advisor_decision_deadline
  end

  def formatted_project_status(project)
    if project.pending? or project.rejected? or project.status_published?
      project.status.capitalize
    elsif !project.status_published?
      "#{project.status.capitalize} (flagged, not published)"
    end
  end

  def formatted_submission_count(project)
    if project.accepted? and project.status_published?
      project.submissions.count
    end
  end

end
