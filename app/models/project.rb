class Project < ActiveRecord::Base

  default_scope { order('projects.created_at DESC') }
  scope :accepted_projects, -> { where(status: "accepted") }
  scope :rejected_projects, -> { where(status: "rejected") }
  scope :pending_projects,  -> { where(status: "pending") }
  # This name is somewhat confusing. Change it to `current_unpublished`?
  scope :current_pending_projects,
    -> { where(status_published: false,
               quarter: Quarter.current_quarter) }
  scope :unpublished_nonpending_projects,
    -> { current_pending_projects.where.not(status: "pending") }
  scope :current_accepted_projects,
    -> { where(status: "accepted").
    joins(:quarter).where(quarters: { current: true }) }
  scope :current_accepted_published_projects,
    -> { where(status: "accepted", status_published: true).
    joins(:quarter).where(quarters: { current: true }) }
  scope :quarter_accepted_projects,
    ->(quarter) { where(status: "accepted").
    joins(:quarter).where(quarters: { id: quarter.id }) }

  attr_accessor :this_user

  belongs_to :quarter
  belongs_to :advisor, class_name: "User", foreign_key: "advisor_id"
  has_many :submissions

  validates :name, presence: true, uniqueness: { scope: :quarter_id,
                                                 case_sensitive: false }
  validates :description, presence: true,
    length: { minimum: 100, maximum: 1500 }
  validates :expected_deliverables, presence: true,
    length: { minimum: 100, maximum: 1500 }
  validates :prerequisites, presence: true,
    length: { minimum: 100, maximum: 1500 }

  validate :creator_role
  validate :created_before_proposal_deadline, on: :create
  validate :status_not_pending_when_published
  validate :advisor_cannot_edit_if_pending, on: :update

  delegate :email, :affiliation, :formatted_affiliation, :formatted_info,
           :formatted_department, :department, :display_name, to: :advisor,
           prefix: :advisor, allow_nil: true
  delegate :formatted_quarter, to: :quarter, prefix: false, allow_nil: true
  delegate :current, to: :quarter, prefix: true, allow_nil: true

  attr_accessor :comments

  after_create :send_project_proposed
  after_update :send_project_status_changed

  def accepted?
    status == "accepted"
  end

  def rejected?
    status == "rejected"
  end

  def pending?
    status == "pending"
  end

  def in_current_quarter?
    self.quarter == Quarter.current_quarter
  end

  def accepted_submissions
    self.submissions.where(status: "accepted")
  end

  def cloneable?
    self.quarter != Quarter.current_quarter and
      self.accepted_submissions.count == 0 and
      !self.cloned?
  end

  def formatted_related_work
    self.related_work.present? ? self.related_work : "N/A"
  end

  def formatted_status_for_admins
    cap_stat = self.status.capitalize
    self.pending? ? cap_stat : "#{cap_stat} (flagged, not published)"
  end

  def has_submissions?
    self.submissions.count > 0
  end

  def submittable_to?
    self.accepted? and self.status_published?
  end

  def format_cloned
    self.cloned? ? "This project has been cloned." :
      "This project has not been cloned."
  end

  private

  def send_project_proposed
    User.admins.each do |admin|
      Notifier.project_proposed(self, admin).deliver
    end
  end

  def send_project_status_changed
    Notifier.project_status_changed(self).deliver
  end

  def creator_role
    errors.add(:advisor, "must be an advisor or admin") if
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
    if this_user.advisor? and !this_user.admin? and !self.pending?
      errors.add(:base, message)
    end
  end

end
