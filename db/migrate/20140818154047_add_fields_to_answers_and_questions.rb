class AddFieldsToAnswersAndQuestions < ActiveRecord::Migration
  def change
    add_column :evaluation_questions, :type, :string
    add_column :evaluation_questions, :prompt, :text
    add_column :evaluation_questions, :active, :boolean

    add_column :evaluation_answers, :response, :text
  end
end
