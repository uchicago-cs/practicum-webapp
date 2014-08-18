class EvaluationQuestion < ActiveRecord::Base

  default_scope { order('evaluation_questions.created_at DESC') }

  belongs_to :evaluation
  has_many :evaluation_answers

end
