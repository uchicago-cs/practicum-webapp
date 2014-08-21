class AddSurveyColumnToEvaluationsTable < ActiveRecord::Migration
  def change
    add_column :evaluations, :survey, :json
  end
end
