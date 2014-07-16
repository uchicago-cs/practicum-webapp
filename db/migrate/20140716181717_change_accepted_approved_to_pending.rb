class ChangeAcceptedApprovedToPending < ActiveRecord::Migration
  def change
    remove_column :submissions, :accepted
    remove_column :projects, :approved

    add_column :submissions, :status, :string, null: false, default: "pending"
    add_column :projects, :status, :string, null: false, default: "pending"
  end
end
