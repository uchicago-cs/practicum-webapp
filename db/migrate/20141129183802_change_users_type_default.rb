class ChangeUsersTypeDefault < ActiveRecord::Migration
  def change
    change_column :users, :type, :string, default: "", null: false
  end
end
