class RemoveCurrentFromQuartersTable < ActiveRecord::Migration
  def change
    remove_column :quarters, :current, :boolean
  end
end
