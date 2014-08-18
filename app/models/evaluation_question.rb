class EvaluationQuestion < ActiveRecord::Base

  default_scope { order('evaluation_questions.created_at DESC') }

  scope :active, -> { where(active: true) }

  has_many :evaluation_questions_evaluations,
           class_name: EvaluationQuestionEvaluationJoin
  has_many :evaluations, through: :evaluation_questions_evaluations
  has_many :evaluation_answers

  def question_type_symbol
    symbols = { "Text field" => :text_field, "Text area" => :text_area,
                "Check box" => :check_box, "Radio button" => :radio_button }
    symbols[question_type]
  end

end
