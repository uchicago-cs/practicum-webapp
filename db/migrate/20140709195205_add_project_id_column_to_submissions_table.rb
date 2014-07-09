class AddProjectIdColumnToSubmissionsTable < ActiveRecord::Migration
  def change
    add_column :submissions, :project_id, :integer
  end
end
