class ActuallyRemoveDefaultsFromQuarterDeadlines < ActiveRecord::Migration
  def change
    change_column_default(:quarters, :start_date,             nil)
    change_column_default(:quarters, :end_date,               nil)
    change_column_default(:quarters, :admin_publish_deadline, nil)
    change_column :quarters, :start_date,             :datetime, null: true
    change_column :quarters, :end_date,               :datetime, null: true
    change_column :quarters, :admin_publish_deadline, :datetime, null: true
  end
end
