class RemoveDefaultsFromQuarterDeadlines < ActiveRecord::Migration
  def change
    change_column :quarters, :start_date,             :datetime
    change_column :quarters, :end_date,               :datetime
    change_column :quarters, :admin_publish_deadline, :datetime
  end
end
