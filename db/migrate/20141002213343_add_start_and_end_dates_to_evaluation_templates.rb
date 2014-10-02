class AddStartAndEndDatesToEvaluationTemplates < ActiveRecord::Migration
  def change
    add_column :evaluation_templates, :start_date, :datetime
    add_column :evaluation_templates, :end_date, :datetime
  end
end
