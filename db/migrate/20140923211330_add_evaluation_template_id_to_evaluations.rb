class AddEvaluationTemplateIdToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :evaluation_template_id, :integer
    add_index  :evaluations, :evaluation_template_id
  end
end
