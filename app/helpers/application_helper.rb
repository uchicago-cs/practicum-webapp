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

end
