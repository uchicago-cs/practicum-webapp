class AddAttachmentResumeToSubmissions < ActiveRecord::Migration
  def self.up
    change_table :submissions do |t|
      t.attachment :resume
    end
  end

  def self.down
    remove_attachment :submissions, :resume
  end
end
