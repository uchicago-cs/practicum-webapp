class AddColumnsToQuarters < ActiveRecord::Migration
  def change
    add_column :quarters, :quarter, :string, default: "", null: false
    add_column :quarters, :year, :integer
  end
end
