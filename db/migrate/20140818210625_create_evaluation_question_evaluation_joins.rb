class CreateEvaluationQuestionEvaluationJoins < ActiveRecord::Migration
  def change
    create_table :evaluation_question_evaluation_joins do |t|

      t.timestamps
    end
  end
end
