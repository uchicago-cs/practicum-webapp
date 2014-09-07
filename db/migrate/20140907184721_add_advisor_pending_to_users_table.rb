class AddAdvisorPendingToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :advisor_status_pending, :boolean, default: false
  end
end
