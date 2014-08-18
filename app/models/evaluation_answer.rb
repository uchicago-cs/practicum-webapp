class EvaluationAnswer < ActiveRecord::Base

  default_scope { order('evaluation_answers.created_at DESC') }

  belongs_to :evaluation_question
  belongs_to :evaluation, through: :evaluation_questions

end
