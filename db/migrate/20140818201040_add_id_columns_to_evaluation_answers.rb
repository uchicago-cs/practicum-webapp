class AddIdColumnsToEvaluationAnswers < ActiveRecord::Migration
  def change
    add_column :evaluation_answers, :evaluation_id, :integer
    add_column :evaluation_answers, :evaluation_question_id, :integer
  end
end
