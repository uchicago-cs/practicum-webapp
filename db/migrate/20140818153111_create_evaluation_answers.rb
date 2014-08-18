class CreateEvaluationAnswers < ActiveRecord::Migration
  def change
    create_table :evaluation_answers do |t|

      t.timestamps
    end
  end
end
