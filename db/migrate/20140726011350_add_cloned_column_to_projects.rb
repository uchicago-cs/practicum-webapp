class AddClonedColumnToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :cloned, :boolean, default: false, null: false
  end
end
