class EvaluationSurvey < ActiveRecord::Base

  validate :no_empty_questions
  serialize :survey
  #serialize :survey, ActiveRecord::Coders::NestedHstore

  # This should be in a helper or decorator.
  def EvaluationSurvey.question_symbols(prompt)
    question_symbols =
      { "Text field" => :text_field, "Text area" => :text_area,
        "Check box" => :check_box, "Radio button" => :radio_button }
    question_symbols[prompt]
  end

  private

  def no_empty_questions
    message = "Questions cannot be blank."
    logger.debug survey.inspect
    errors.add(:base, message) if
      survey.values.any? { |question| question.values.any?(&:blank?) }
  end

end
