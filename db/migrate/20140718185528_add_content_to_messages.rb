class AddContentToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :content,     :text, null: false, default: ""
    add_column :messages, :sender,    :string, null: false, default: ""
    add_column :messages, :recipient, :string, null: false, default: ""
  end
end
