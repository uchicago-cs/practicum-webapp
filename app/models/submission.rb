class Submission < ActiveRecord::Base

  belongs_to :user, foreign_key: "student_id"
  belongs_to :project

  validates :information, presence: true,
    length: { minimum: 100, maximum: 1500 }
  validates :qualifications, presence: true,
    length: { minimum: 100, maximum: 1500 }
  validates :courses, presence: true,
    length: { minimum: 100, maximum: 1500 }
  validates :student_id, presence: true

  delegate :name, to: :project, prefix: true
  delegate :email, to: :user, prefix: :student

  has_attached_file :resume,
                    url: "/assets/submissions/:id/:style/:basename.:extension",
                    path: ":rails_root/assets/submissions/:id/:style/:basename.:extension"
  validates_attachment_content_type :resume,
    content_type: /\Aapplication\/(pdf|doc|docx)\z/,
    message: "Resume must be .pdf, .doc, or .docx"
  # See http://blog.blenderbox.com/2011/01/31/
  # uploading-docx-files-with-paperclip-and-rails/.
  # use 'resume' instead of 'attachment' in L11?
  validates_attachment_file_name :resume, matches: /(pdf|doc|docx)\z/
  validates_attachment_size :resume, less_than: 5.megabytes
  # Could even use 1.megabyte.

  def student
    User.find(student_id)
    # Not ideal
  end

  def accepted?
    status == "accepted"
  end

  def rejected?
    status == "rejected"
  end

  def pending?
    status == "pending"
  end

end
