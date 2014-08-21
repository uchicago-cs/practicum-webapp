class AddSurveyColumnToTemplatesTable < ActiveRecord::Migration
  def change
    add_column :evaluation_surveys, :survey, :json
  end
end
