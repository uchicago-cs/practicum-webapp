class MakeAcceptedApprovedNullByDefault < ActiveRecord::Migration
  def change
    change_column :submissions, :accepted, :boolean, null: true, default: nil
    change_column :projects, :approved, :boolean, null: true, default: nil
  end
end
