class AddCurrentBooleanToQuarter < ActiveRecord::Migration
  def change
    add_column :quarters, :current, :boolean
  end
end
