class ChangeSurveyToHstore < ActiveRecord::Migration
  def change
    remove_column :evaluation_surveys, :survey
    add_column :evaluation_surveys, :survey, :text
  end
end
