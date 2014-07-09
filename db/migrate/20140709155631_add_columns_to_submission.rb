class AddColumnsToSubmission < ActiveRecord::Migration
  def change
    add_column :submissions, :student_id, :integer
    add_column :submissions, :information, :text, default: "", null: false
  end
end
