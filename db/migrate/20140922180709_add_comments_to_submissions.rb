class AddCommentsToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :comments, :text, default: ""
  end
end
