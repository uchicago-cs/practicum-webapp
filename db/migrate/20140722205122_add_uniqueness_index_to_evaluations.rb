class AddUniquenessIndexToEvaluations < ActiveRecord::Migration
  def change
    add_index :evaluations, [:student_id, :project_id], unique: true
  end
end
