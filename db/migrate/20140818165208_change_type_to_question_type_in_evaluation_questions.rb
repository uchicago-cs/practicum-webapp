class ChangeTypeToQuestionTypeInEvaluationQuestions < ActiveRecord::Migration
  def change
    rename_column :evaluation_questions, :type, :question_type
  end
end
