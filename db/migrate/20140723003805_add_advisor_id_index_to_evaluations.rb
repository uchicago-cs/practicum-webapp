class AddAdvisorIdIndexToEvaluations < ActiveRecord::Migration
  def change
    add_index :evaluations, :advisor_id
  end
end
