class ChangeProjectsNameIndex < ActiveRecord::Migration
  def change
    add_column :projects, :quarter_id, :integer
    remove_index :projects, :name
    add_index :projects, [:name, :quarter_id], unique: true
  end
end
