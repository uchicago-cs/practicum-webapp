class AddStatusPublishedColumnToProjectsTable < ActiveRecord::Migration
  def change
    add_column :projects, :status_published, :boolean, default: false
  end
end
