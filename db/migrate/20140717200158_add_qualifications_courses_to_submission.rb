class AddQualificationsCoursesToSubmission < ActiveRecord::Migration
  def change
    add_column :submissions, :qualifications, :text, null: false, default: ""
    add_column :submissions, :courses, :text, null: false, default: ""
  end
end
