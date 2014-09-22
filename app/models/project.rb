class Project < ActiveRecord::Base

  include StatusMethods

  default_scope { order('projects.created_at DESC') }
  scope :accepted_projects, -> { where(status: "accepted") }
  scope :rejected_projects, -> { where(status: "rejected") }
  scope :pending_projects,  -> { where(status: "pending") }
  scope :current_unpublished_projects,
    -> { where(status_published: false,
               quarter: Quarter.current_quarter).
         where("status != ?", "draft") }
  scope :unpublished_nonpending_projects,
    -> { current_unpublished_projects.where.not(status: "pending") }
  scope :current_accepted_projects,
    -> { where(status: "accepted").
    joins(:quarter).where(quarters: { current: true }) }
  scope :current_accepted_published_projects,
    -> { where({status: "accepted", status_published: true}).
    joins(:quarter).where(quarters: { current: true }) }
  scope :quarter_accepted_projects,
    ->(quarter) { where(status: "accepted").
    joins(:quarter).where(quarters: { id: quarter.id }) }

  attr_accessor :this_user
  attr_accessor :comments

  belongs_to :quarter
  belongs_to :advisor, class_name: "User", foreign_key: "advisor_id"
  has_many :submissions

  validates :name, presence: true, uniqueness: { scope: :quarter_id,
                                                 case_sensitive: false }
  validates :description, presence: true
  validates :expected_deliverables, presence: true
  validates :prerequisites, presence: true

  validate :creator_role
  validate :created_before_proposal_deadline, on: :create
  validate :status_not_pending_when_published
  validate :advisor_cannot_edit_if_pending, on: :update

  delegate :email, :affiliation, :department, to: :advisor,
           prefix: :advisor, allow_nil: true
  delegate :current, to: :quarter, prefix: true, allow_nil: true

  after_create :send_project_proposed_immediately
  after_update :send_project_proposed_after_draft
  after_update :send_project_status_changed

  def accepted_submissions
    self.submissions.where(status: "accepted")
  end

  def cloneable?
    self.quarter != Quarter.current_quarter and
      self.accepted_submissions.count == 0 and
      !self.cloned?
  end

  def has_submissions?
    self.submissions.count > 0
  end

  def submittable_to?
    self.accepted? and self.status_published?
  end

  def submitted_submissions
    self.submissions.where.not(status: "draft")
  end

  private

  def send_project_proposed_immediately
    # See Submission#send_student_applied.
    if self.status == "pending"
      User.admins.each { |ad| Notifier.project_proposed(self, ad).deliver }
    end
  end

  def send_project_proposed_after_draft
    if self.status_changed?(from: "draft", to: "pending")
      User.admins.each { |ad| Notifier.project_proposed(self, ad).deliver }
    end
  end

  def send_project_status_changed
    # See Submission#send_status_updated.
    if !(self.status_changed?(from: "draft"))
      if status_changed?
        Notifier.project_status_changed(self).deliver
      end

      if status_published_changed? and status == "accepted"
        Notifier.project_status_published_accepted(self).deliver
      end
    end
  end

  def creator_role
    errors.add(:base, "The project creator must be an advisor or admin.") if
      ( advisor.roles == ["student"] or advisor.roles == [] )
  end

  # Do we also need to check that this is a current project?
  def created_before_proposal_deadline
    errors.add(:base, "The proposal deadline has passed.") if
      DateTime.now > Quarter.current_quarter.project_proposal_deadline
  end

  def accepted_before_submission_deadline
    message = "Cannot accept projects after the application deadline."
    errors.add(:base, message) if self.status_changed? and
      self.accepted? and
      DateTime.now > Quarter.current_quarter.student_submission_deadline
  end

  def status_not_pending_when_published
    message = "Status must be accepted or rejected before it " \
              "can be published."
    errors.add(:base, message) if self.pending? and self.status_published?
  end

  def advisor_cannot_edit_if_pending
    message = "Advisors can only edit proposals that are pending " \
              "approval."
    # Ideally, get rid of `this_user`; it makes setting up and debugging the
    # specs a bit more difficult.
    if this_user.try(:advisor?) and !this_user.try(:admin?) and !self.pending?
      errors.add(:base, message)
    end
  end

end
