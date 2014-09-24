module EvaluationsHelper

  def formatted_answer(answer)
    answer.present? ? answer : "(Unanswered)"
  end

  def question_symbols(q_type)
    question_symbols =
      { "Text field" => :text_field, "Text area" => :text_area,
        "Check box" => :check_box, "Radio button" => :radio_button }
    question_symbols[q_type]
  end

  def question_necessity(question)
    if question["question_mandatory"] == "1"
      "(required)".html_safe
    else
      content_tag(:span, "(optional)", class: "question-mandatory")
    end
  end

  def response_input(question, form)
    if question["question_type"] == "Check box"

      checked = nil
      # Check box if input was invalid and the user checked it before.
      if params[:survey]
        is_yes = (params[:survey]["#{question['question_prompt']}"] == "Yes")
        checked = is_yes ? true : false
      end
      form.check_box("survey[#{question['question_prompt']}]",
                     label: "", inline: true,
                     checked: checked)

    elsif question["question_type"] == "Radio button"

      form.form_group(question["question_prompt"],
                      class: 'eval-radio-btn') do

        concat(form.hidden_field "survey[#{question['question_prompt']}]")
        question["question_options"].collect do |num, opt|
          # Select `opt` if input was invalid and user selected `opt` before.
          checked = nil
          if params[:survey]
            checked = params[:survey]["#{question['question_prompt']}"] == opt
          end
          concat(form.radio_button("survey[#{question['question_prompt']}]",
                                   opt, label: opt, checked: checked))
        end

      end

    else
      form.send(question_symbols(question["question_type"]),
	       "survey[#{question['question_prompt']}]",
	       hide_label: true,
	       value: params[:survey] ?
	       params[:survey]["#{question['question_prompt']}"] : nil )
    end

  end

  def question_options(question)
    if question["question_type"] == "Radio button"
      question["question_options"].collect do |num, opt|
        content_tag(:p, "#{num}. #{opt}")
      end.join.html_safe
    end
  end

end
