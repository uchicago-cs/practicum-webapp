class DropEEQ < ActiveRecord::Migration
  def change
    drop_table :evaluations_evaluation_questions

    create_table :evaluation_questions_evaluations do |t|
      t.integer :evaluation_id,          null: false
      t.integer :evaluation_question_id, null: false
    end
  end
end
