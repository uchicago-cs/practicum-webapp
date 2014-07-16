class MakeAcceptedAndApprovedColumnsNullable < ActiveRecord::Migration
  def change
    change_column :submissions, :accepted, :boolean, null: true
    change_column :projects, :approved, :boolean, null: true
  end
end
