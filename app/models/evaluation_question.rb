class EvaluationQuestion < ActiveRecord::Base

  default_scope { order('evaluation_questions.created_at DESC') }

  scope :active, -> { where(active: true) }

  has_and_belongs_to_many :evaluations
  has_many :evaluation_answers

  def question_type_symbol
    symbols = { "Text field" => :text_field, "Text area" => :text_area,
                "Check box" => :check_box, "Radio button" => :radio_button }
    symbols[question_type]
  end

end
