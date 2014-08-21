class EvaluationSurvey < ActiveRecord::Base

  validate :no_empty_questions
  serialize :survey
  #serialize :survey, ActiveRecord::Coders::NestedHstore

  private

  def no_empty_questions
    message = "Questions cannot be blank."
    logger.debug survey.inspect
    errors.add(:base, message) if
      survey.values.any? { |question| question.values.any?(&:blank?) }
  end

end
