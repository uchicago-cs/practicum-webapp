class AddColumnsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :name, :string, default: "", null: false
    add_column :projects, :advisor_id, :integer
    add_column :projects, :approved, :boolean, default: false, null: false
    add_column :projects, :deadline, :date
    add_column :projects, :description, :text, default: "", null: false
  end
end
