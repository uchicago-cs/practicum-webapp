class UserStudentByDefault < ActiveRecord::Migration
  def change
    change_column :users, :student, :boolean, null: false, default: true
  end
end
