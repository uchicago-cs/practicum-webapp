class AddQuarterIndexToEvaluationTemplates < ActiveRecord::Migration
  def change
    add_index :evaluation_templates, :quarter_id
  end
end
