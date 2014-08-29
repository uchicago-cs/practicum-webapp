module EvaluationsHelper

  def db_template
    EvaluationTemplate.first || EvaluationTemplate.new
  end

end
