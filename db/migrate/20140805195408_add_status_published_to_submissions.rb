class AddStatusPublishedToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :status_published, :boolean, default: false
  end
end
