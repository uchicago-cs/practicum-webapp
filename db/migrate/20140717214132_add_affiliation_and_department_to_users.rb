class AddAffiliationAndDepartmentToUsers < ActiveRecord::Migration
  def change
    add_column :users, :affiliation, :string, null: false, default: ""
    add_column :users, :department,  :string, null: false, default: ""
  end
end
