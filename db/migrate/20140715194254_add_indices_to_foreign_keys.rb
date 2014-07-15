class AddIndicesToForeignKeys < ActiveRecord::Migration
  def change
    add_index :projects, :advisor_id
    add_index :submissions, :student_id
  end
end
