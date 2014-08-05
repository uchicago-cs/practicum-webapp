class AddStatusApprovedToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :status_approved, :boolean, default: false
  end
end
