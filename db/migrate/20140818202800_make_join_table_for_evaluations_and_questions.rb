class MakeJoinTableForEvaluationsAndQuestions < ActiveRecord::Migration
  def change
    create_table :evaluations_evaluation_questions, id: false do |t|
      t.belongs_to :evaluation
      t.belongs_to :evaluation_questions
    end
  end
end
