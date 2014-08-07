class Submission < ActiveRecord::Base

  belongs_to :user, foreign_key: "student_id"
  belongs_to :project
  has_one :evaluation, foreign_key: "submission_id", dependent: :destroy

  validates :information, presence: true,
    length: { minimum: 100, maximum: 1500 }
  validates :qualifications, presence: true,
    length: { minimum: 100, maximum: 1500 }
  validates :courses, presence: true,
    length: { minimum: 100, maximum: 1500 }
  validates :student_id, presence: true
  validates_uniqueness_of :student_id, scope: :project_id

  # on: :update?
  validate :status_not_pending_before_approved
  validate :status_not_pending_before_published
  validate :status_approved_before_published
  # validate :status_approved_after_advisor_deadline
  validate :status_published_after_advisor_deadline
  validate :created_before_submission_deadline, on: :create
  validate :decision_made_before_decision_deadline

  delegate :name, to: :project, prefix: true, allow_nil: true
  delegate :quarter, to: :project, prefix: false, allow_nil: true
  delegate :email, to: :user, prefix: :student, allow_nil: true
  delegate :advisor_id, :advisor_email,
           to: :project, prefix: true, allow_nil: true

  after_create :send_student_applied
  after_update :send_respective_update

  has_attached_file :resume,
                    url: "/projects/:project_id/submissions/:id/resume",
                    path: ":rails_root/storage/assets/submissions/:id/:style/:basename.:extension"
  validates_attachment_content_type :resume,
    content_type: /\Aapplication\/(pdf|doc|docx)\z/,
    message: "Resume must be .pdf, .doc, or .docx"
  # See http://blog.blenderbox.com/2011/01/31/
  # uploading-docx-files-with-paperclip-and-rails/.
  # use 'resume' instead of 'attachment' in L11?
  validates_attachment_file_name :resume, matches: /(pdf|doc|docx)\z/
  validates_attachment_size :resume, less_than: 5.megabytes
  # Could even use 1.megabyte.

  def Submission.current_submissions
    Submission.joins(:project). \
      where(projects: { quarter_id: Quarter.current_quarter.id })
  end

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

  def formatted_status_for_advisor
    # Put in helper, presenter, or decorator.
    message = "#{status.capitalize} (pending administrator approval)"
    (!status_approved and !pending?) ? message : status.capitalize
  end

  def formatted_status_for_student
    status_published ? status.capitalize : "Pending"
  end

  def in_current_quarter?
    self.quarter == Quarter.current_quarter
  end

  def status_sufficient?
    self.accepted? and self.status_approved? and self.status_published?
  end

  private

  def send_student_applied
    Notifier.student_applied(self.project.advisor,
                             self.student).deliver
    User.admins.each do |admin|
      Notifier.student_applied(admin, self.student).deliver
    end
  end

  def send_respective_update
    if self.accepted?
      # Confusing name -- change to accept_submission?
      Notifier.accept_student(self).deliver
    elsif self.rejected?
      Notifier.reject_student(self).deliver
    end
  end

  # Make #in_current_quarter? its own check. Also, add error messages.
  def status_not_pending_before_approved
    message = "Status must not be pending before an admin can approve it."
    errors.add(:base, message) if self.pending? and self.status_approved? \
      and self.in_current_quarter?
  end

  def status_not_pending_before_published
    message = "Status must not be pending before an admin can publish it."
    errors.add(:base, message) if self.pending? \
      and self.status_published? and self.in_current_quarter?
  end

  def status_approved_before_published
    message = "Status must be approved before it can be published."
    errors.add(:base, message) if !self.status_approved? \
      and self.status_published? and self.in_current_quarter?
  end

  # def status_approved_after_advisor_deadline
  #   errors.add(:status_approved) if self.status_approved \
  #     and DateTime.now <= Quarter.current_quarter.advisor_decision_deadline \
  #     and self.in_current_quarter?
  # end

  def status_published_after_advisor_deadline
    message = "Cannot publish status before the advisor's decision deadline."
    errors.add(:base, message) if self.status_published \
      and DateTime.now <= Quarter.current_quarter.advisor_decision_deadline \
      and self.in_current_quarter?
  end

  def created_before_submission_deadline
    message = "The application deadline has passed."
    errors.add(:base, message) if \
      DateTime.now > Quarter.current_quarter.student_submission_deadline \
      and self.in_current_quarter?
  end

  def decision_made_before_decision_deadline
    message = "Status cannot be updated past the advisor's decision deadline."
    errors.add(:base, message) if !self.pending? and self.status_changed? \
      and DateTime.now > Quarter.current_quarter.advisor_decision_deadline \
      and self.in_current_quarter?
  end

end
