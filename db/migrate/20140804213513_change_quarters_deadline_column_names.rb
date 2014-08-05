class ChangeQuartersDeadlineColumnNames < ActiveRecord::Migration
  def change
    rename_column :quarters, :proposal_deadline, :project_proposal_deadline
    rename_column :quarters, :submission_deadline, :student_submission_deadline
  end
end
