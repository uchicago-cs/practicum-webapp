module EvaluationTemplatesHelper

  def formatted_template_title(template)
    "#{formatted_quarter(template.quarter)} #{template.name.titleize} Template"
  end

  def active_warning
    "Setting this template to \"active\" will set all others in this " +
      "quarter to \"inactive\"."
  end

  def survey_has_questions?(template)
    template and template.survey and template.survey.length > 0
  end

  def formatted_active(template)
    template.active? ? "Yes" : "No"
  end

  # Ideally, find a better fix for this.
  def db_template(template)
    EvaluationTemplate.find(template.id)
  end

  def box_checked(number, template)
    (db_template(template).survey[number]["question_mandatory"] == "1") ?
    true : false
  end

  def sorted_option_indices(template)
    db_template(template).survey.keys.sort
  end

end
