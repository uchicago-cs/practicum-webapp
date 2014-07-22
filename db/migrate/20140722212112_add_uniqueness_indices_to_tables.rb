class AddUniquenessIndicesToTables < ActiveRecord::Migration
  def change
    add_index :projects, :name, unique: true
    add_index :submissions, [:student_id, :project_id], unique: true
  end
end
