module EvaluationTemplatesHelper

  def formatted_active(template)
    template.active? ? "Yes" : "No"
  end

end
