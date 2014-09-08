class RemoveCommentsFromEvaluationsTable < ActiveRecord::Migration
  def change
    remove_column :evaluations, :comments
  end
end
