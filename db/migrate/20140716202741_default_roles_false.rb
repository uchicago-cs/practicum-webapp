class DefaultRolesFalse < ActiveRecord::Migration
  def change
    change_column :users, :admin,   :boolean, null: false, default: false
    change_column :users, :advisor, :boolean, null: false, default: false
    change_column :users, :student, :boolean, null: false, default: false
  end
end
