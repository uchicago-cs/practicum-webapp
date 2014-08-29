class RenameEvalSurveysToEvalTemplates < ActiveRecord::Migration
  def change
    rename_table :evaluation_surveys, :evaluation_templates
  end
end
