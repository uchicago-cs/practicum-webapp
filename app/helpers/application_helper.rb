module ApplicationHelper

  # Refactor these three into one method.
  def project_proposal_deadline
    Quarter.current_quarter.project_proposal_deadline. \
      strftime("%I:%M %p on %D (%A, %B %d, %Y)")
  end

  def student_submission_deadline
    Quarter.current_quarter.student_submission_deadline. \
      strftime("%I:%M %p on %D (%A, %B %d, %Y)")
  end

  def advisor_decision_deadline
    Quarter.current_quarter.advisor_decision_deadline. \
      strftime("%I:%M %p on %D (%A, %B %d, %Y)")
  end

  def admin_publish_deadline
    Quarter.current_quarter.admin_publish_deadline. \
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

  # def before_deadline?(deadline_type)
  #   types = { "proposal" => :project_proposal_deadline,
  #     "submission" => :student_submission_deadline }
  #   DateTime.now <= Quarter.current_quarter.send(types[deadline_type])
  # end

  # def formatted_project_status(project)
  #   cap_stat = project.status.capitalize
  #   status_for_admins = project.pending? ? cap_stat : \
  #   "#{cap_stat} (flagged, not published)"
  #   current_user.admin? ? status_for_admins : "Pending"
  # end

  def formatted_project_status(project)
    if current_user.admin?

      if project.pending? or project.status_published?
        project.status.capitalize
      elsif !project.status_published?
        "#{project.status.capitalize} (flagged, not published)"
      end

    else # elsif current_user.advisor?

      if project.status_published?
        project.status.capitalize
      else
        "Pending"
      end

    end
  end

  def formatted_submission_count(project)
    if project.accepted? and project.status_published?
      project.submissions.count
    end
  end

end
