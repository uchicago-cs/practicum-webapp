class AddDeadlineAttributesToQuartersTable < ActiveRecord::Migration
  def change
    add_column :quarters, :proposal_deadline, :datetime
    add_column :quarters, :submission_deadline, :datetime
  end
end
