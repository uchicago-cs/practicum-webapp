class AddAcceptedColumnToSubmissionsTable < ActiveRecord::Migration
  def change
    add_column :submissions, :accepted, :boolean, default: false
  end
end
