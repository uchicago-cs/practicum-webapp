class SetRoleDefaultsFalse < ActiveRecord::Migration
  def change
    change_column :users, :student, :boolean, null: false, default: true
    change_column :users, :advisor, :boolean, null: false, default: true
    change_column :users, :admin,   :boolean, null: false, default: true
  end
end
