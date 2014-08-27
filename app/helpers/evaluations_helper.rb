module EvaluationsHelper

  def db_template
    EvaluationSurvey.first || EvaluationSurvey.new
  end

end
