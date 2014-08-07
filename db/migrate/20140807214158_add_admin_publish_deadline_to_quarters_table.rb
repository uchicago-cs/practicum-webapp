class AddAdminPublishDeadlineToQuartersTable < ActiveRecord::Migration
  def change
    add_column :quarters, :admin_publish_deadline, :datetime,
               default: DateTime.now + 9.weeks + 5.days + 17.hours
  end
end
