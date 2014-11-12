class Submission < ActiveRecord::Base

  include StatusMethods

  default_scope { order('submissions.created_at DESC') }
  scope :current_submissions, -> { includes(:project).
      where(projects: { quarter_id: Quarter.current_quarter.id }) }
  scope :current_submitted_submissions, -> { current_submissions.
    where.not(status: "draft") }
  scope :current_unsubmitted_submissions, -> { current_submissions.
    where(status: "draft") }

  attr_accessor :this_user
  attr_accessor :update_in_index
  attr_accessor :applicant

  belongs_to :student, class_name: "User", foreign_key: "student_id"
  belongs_to :project
  has_many :evaluations, foreign_key: "submission_id"

  validates :information, presence: true
  validates :qualifications, presence: true
  validates :courses, presence: true
  validates :student_id, presence: true
  validates_uniqueness_of :student_id, scope: :project_id

  validate :status_not_pending_before_approved
  validate :status_not_pending_before_published
  validate :status_approved_before_published
  validate :created_before_submission_deadline, on: :create,
           unless: Proc.new { |sub| sub.applicant.present? }
  validate :decision_made_before_decision_deadline
  validate :creator_role, on: :create
  validate :created_when_project_visible, on: :create
  validate :project_is_in_current_quarter, on: :create

  delegate :name, to: :project, prefix: true, allow_nil: true
  delegate :quarter, to: :project, prefix: false, allow_nil: true
  delegate :email, to: :student, prefix: :student, allow_nil: true
  delegate :advisor_id, :advisor_email,
           to: :project, prefix: true, allow_nil: true

  after_create      :send_student_applied_immediately
  after_update      :send_student_applied_after_draft
  after_update      :send_status_updated
  before_validation :downcase_status

  has_attached_file :resume,
                    url: "/submissions/:id/resume",
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

  def active_eval_createable?
    status_sufficient? and active_eval_not_made? and
      EvaluationTemplate.current_active_available?
  end

  def status_sufficient?
    self.accepted? and self.status_approved? and self.status_published?
  end

  def Submission.update_selected(params)
    case params[:commit]
    when "Accept all selected"
      Submission.update_selected_values(params, :status, "accepted")
    when "Reject all selected"
      Submission.update_selected_values(params, :status, "rejected")
    when "Approve decisions of all selected"
      Submission.update_selected_values(params, :status_approved, true)
    when "Reject decisions of all selected"
      Submission.update_selected_values(params, :status_approved, false)
    when "Publish all selected"
      Submission.update_selected_values(params, :status_published, true)
    when "Unpublish all selected"
      Submission.update_selected_values(params, :status_published, false)
    end
  end

  def active_eval_not_made?
    templates = self.evaluations.collect { |e| e.evaluation_template }
    !(templates.include? EvaluationTemplate.current_active)
  end

  private

  def Submission.update_selected_values(params, _attr, _val)
    params[:submissions].each do |submission|
      if (submission[1][:update_in_index].to_i == 1 ? true : false)
        Submission.find(submission[0]).update_attributes("#{_attr}" => _val)
      end
    end
  end

  def send_student_applied_immediately
    Notifier.student_applied(self).deliver if self.status == "pending"
  end

  def send_student_applied_after_draft
    # Maybe even just `from: "draft"`; leave off `to: "pending"`?
    if self.status_changed?(from: "draft", to: "pending")
      Notifier.student_applied(self).deliver
    end
  end

  def send_status_updated
    # Send only if the status was not originally "draft".
    if !(self.status_changed?(from: "draft"))
      # Ideally, don't use this_user here.
      if status_changed? and !this_user.try(:admin?)
        User.admins.each do
          |admin| Notifier.submission_status_updated(self, admin).deliver
        end
      end

      if status_published_changed?
        Notifier.submission_status_publish(self).deliver
      end
    end
  end

  # Make #in_current_quarter? its own check.
  def status_not_pending_before_approved
    message = "Status must not be pending before an admin can approve it."
    errors.add(:base, message) if self.pending? and self.status_approved? and
      self.status_approved_changed?
  end

  def status_not_pending_before_published
    message = "Status must not be pending before an admin can publish it."
    errors.add(:base, message) if self.pending? and
      self.status_published?
  end

  def status_approved_before_published
    message = "Status must be approved before it can be published."
    errors.add(:base, message) if !self.status_approved? and
      self.status_published?
  end

  def status_published_after_advisor_deadline
    message = "Cannot publish status before the advisor's decision deadline."
    errors.add(:base, message) if self.status_published and
      DateTime.now <= Quarter.current_quarter.advisor_decision_deadline
  end

  def created_before_submission_deadline
    message = "The application deadline has passed."
    errors.add(:base, message) if
      DateTime.now > Quarter.current_quarter.student_submission_deadline
  end

  def decision_made_before_decision_deadline
    message = "Status cannot be updated past the advisor's decision deadline."
    errors.add(:base, message) if !self.pending? and self.status_changed? and
      DateTime.now > Quarter.current_quarter.advisor_decision_deadline and
      !self.this_user.try(:admin?)
  end

  def creator_role
    errors.add(:base, "User must be a student.") unless
      "student".in? student.roles
  end

  def created_when_project_visible
    msg = "Project must be approved and published before it can be applied to."
    errors.add(:base, msg) unless
      (project.status == "accepted" and project.status_published?)
  end

  def downcase_status
    self.status.downcase!
  end

  def project_is_in_current_quarter
    msg = "Applications cannot be submitted to projects from previous " +
      "quarters."
    errors.add(:base, msg) unless project.in_current_quarter?
  end

end
