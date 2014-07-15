class ChangeDeadlineDateToDatetime < ActiveRecord::Migration
  def change
    change_column :projects, :deadline, :datetime
  end
end
