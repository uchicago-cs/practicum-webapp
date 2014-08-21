class ChangeSurveyToTextInEvaluationsTable < ActiveRecord::Migration
  def change
    remove_column :evaluations, :survey
    add_column :evaluations, :survey, :text
  end
end
