class CreateEvaluationQuestions < ActiveRecord::Migration
  def change
    create_table :evaluation_questions do |t|

      t.timestamps
    end
  end
end
