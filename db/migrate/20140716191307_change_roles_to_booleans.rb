class ChangeRolesToBooleans < ActiveRecord::Migration
  def change
    remove_column :users, :role

    add_column :users, :student, :boolean, null: false, default: true
    add_column :users, :advisor, :boolean, null: false, default: true
    add_column :users, :admin,   :boolean, null: false, default: true
  end
end
