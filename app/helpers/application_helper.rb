module ApplicationHelper

  def before_proposal_deadline?
    DateTime.now <= Quarter.current_quarter.project_porposal_deadline
  end

  def before_submission_deadline?
    DateTime.now <= Quarter.current_quarter.student_submission_deadline
  end

  # def before_deadline?(deadline_type)
  #   types = { "proposal" => :project_proposal_deadline,
  #     "submission" => :student_submission_deadline }
  #   DateTime.now <= Quarter.current_quarter.send(types[deadline_type])
  # end

end
