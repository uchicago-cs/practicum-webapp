class AddAdvisorDecisionDeadlineToQuartersTable < ActiveRecord::Migration
  def change
    add_column :quarters, :advisor_decision_deadline, :datetime
  end
end
