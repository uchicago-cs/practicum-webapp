class AddCnetToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cnet, :string, default: "", null: false
  end
end
