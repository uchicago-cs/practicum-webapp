class EvaluationTemplate < ActiveRecord::Base

  validate :no_empty_questions
  validate :no_empty_radio_btn_opts
  validate :no_repeated_questions

  serialize :survey

  # This should be in a helper or decorator.
  def EvaluationTemplate.question_symbols(q_type)
    question_symbols =
      { "Text field" => :text_field, "Text area" => :text_area,
        "Check box" => :check_box, "Radio button" => :radio_button }
    question_symbols[q_type]
  end

  def delete_questions(delete_params)
    delete = false
    delete_params.each do |question_num, should_be_removed|
      if (should_be_removed == "1" ? true : false)
        survey.reject! { |key| key == question_num.to_i }
        delete = true
        # We're not `break`ing here, because we want to delete each question
        # that was marked as delete.
      end
    end
    delete
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

  def change_mandatory(mandatory_params)
    # If possible, store `required` as a bool... (Is this possible, since
    # survey is a text object?)
    mandatory_params.each do |number, required|
      survey[number.to_i]["question_mandatory"] = required
    end
  end

  def edit_question(question_params)
    num    = question_params[:question_num].to_i
    type   = question_params[:question_type]
    prompt = question_params[:question_prompt]

    survey[num]["question_type"]   = type
    survey[num]["question_prompt"] = prompt
    if type == "Radio button"
      survey[num]["question_options"] = question_params[:radio_button_options]
    end
  end

  private

  def no_empty_questions
    message = "Questions cannot be blank."
    errors.add(:base, message) if
      survey.values.any? { |question| question.values.any?(&:blank?) }
  end

  def no_empty_radio_btn_opts
    blank_opts = false
    survey.each do |q, r|
      survey.find_all {|k, h| h["question_type"]=="Radio button"}.each do |opt|
        opt[1]["question_options"].each do |num, option|
          if option.blank?
            blank_opts = true
            break
          end
        end
      end
    end

    message = "Radio button options cannot be blank."
    errors.add(:base, message) if blank_opts
  end

  def no_repeated_questions
    message = "Each question must be unique."
    prompts = survey.values.collect { |q| q["question_prompt"] }
    errors.add(:base, message) if prompts.length != prompts.uniq.length
  end

end
