class AddSubmissionIdToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :submission_id, :integer
    change_column :evaluations, :comments, :text, default: "", null: false
  end
end
