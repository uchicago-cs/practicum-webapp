class AddTextAttributesToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :expected_deliverables, :text, null: false, default: ""
    add_column :projects, :prerequisites, :text, null: false, default: ""
    add_column :projects, :related_work, :text, null: false, default: ""
  end
end
