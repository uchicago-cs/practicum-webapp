class EvaluationQuestionEvaluationJoin < ActiveRecord::Base

  self.table_name = "evaluation_questions_evaluations"

  belongs_to :evaluation
  belongs_to :evaluation_question

end
