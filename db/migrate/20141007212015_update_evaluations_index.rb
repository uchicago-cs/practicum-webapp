class UpdateEvaluationsIndex < ActiveRecord::Migration
  def change
    remove_index :evaluations, [:student_id, :project_id]
    add_index :evaluations, [:student_id, :project_id,
                             :evaluation_template_id], unique: true,
    name: "index_evaluations_on_student_and_project_and_template"
  end
end
