class ChangeQuarterAttributeToSeason < ActiveRecord::Migration
  def change
    remove_column :quarters, :quarter
    add_column :quarters, :season, :string, default: "", null: false
  end
end
