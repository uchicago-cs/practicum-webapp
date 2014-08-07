class AddStartAndEndDateColumnsToQuartersTable < ActiveRecord::Migration
  def change
    add_column :quarters, :start_date, :datetime, null: false,
               default: DateTime.now
    add_column :quarters, :end_date,   :datetime, null: false,
               default: DateTime.now + 10.weeks + 5.days
  end
end
