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

  def reorganize_questions_after_deletion
    ordered_nums = survey.keys.sort
    ordered_nums.each_with_index do |num, index|
      if num != (index + 1)
        # If num == (index + 1), we would remove the pre-existing pair with
        # #reject!.
        survey[index+1] = survey[num]
        survey.reject! { |key| key == num }
      end
    end
  end

  def change_order(ordering_params)
    survey_copy = survey.clone
    ordering_params.each do |old_position, new_position|
      if old_position != new_position
        survey[new_position.to_i] = survey_copy[old_position.to_i]
      end
    end
  end

  private

  def no_empty_questions
    message = "Questions cannot be blank."
    logger.debug survey.inspect
    errors.add(:base, message) if
      survey.values.any? { |question| question.values.any?(&:blank?) }
  end

end
