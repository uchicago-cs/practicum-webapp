class RemoveDeadlineColumnFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :deadline
  end
end
