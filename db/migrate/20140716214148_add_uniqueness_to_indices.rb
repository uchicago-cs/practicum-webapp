class AddUniquenessToIndices < ActiveRecord::Migration
  def change
    remove_index :submissions, :student_id
    remove_index :projects, :advisor_id

    add_index :submissions, :student_id, unique: true
    add_index :projects, :advisor_id, unique: true
  end
end
