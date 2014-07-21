class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.integer :advisor_id
      t.integer :student_id
      t.integer :project_id
      t.text :comments

      t.timestamps
    end
  end
end
