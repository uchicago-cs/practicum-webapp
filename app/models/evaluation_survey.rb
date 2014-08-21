class EvaluationSurvey < ActiveRecord::Base

  validate :no_empty_questions

  private

  def no_empty_questions
    message = "Questions cannot be blank."
    logger.debug "#{survey.to_hash}"
    errors.add(:base, message) if
      survey.to_hash.values.each do |question|
      question["question_prompt"].blank?
    end
  end

end
