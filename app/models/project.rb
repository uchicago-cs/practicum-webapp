class Project < ActiveRecord::Base

  belongs_to :quarter
  belongs_to :user, foreign_key: "advisor_id"
  has_many :submissions

  validates :name, presence: true, uniqueness: { scope: :quarter_id,
                                                 case_sensitive: false }
  validates :deadline, presence: true
  validates :description, presence: true,
    length: { minimum: 100, maximum: 1500 }
  validates :expected_deliverables, presence: true,
    length: { minimum: 100, maximum: 1500 }
  validates :prerequisites, presence: true,
    length: { minimum: 100, maximum: 1500 }

  validate :creator_role
  validate :created_before_proposal_deadline, on: :create
  validate :status_not_pending_when_published

  delegate :email, :affiliation, :formatted_affiliation, :formatted_department,
           :department, :formatted_info, to: :user, prefix: :advisor,
           allow_nil: true
  delegate :formatted_quarter, to: :quarter, prefix: false, allow_nil: true
  # prefix true on this?
  delegate :current, to: :quarter, prefix: true, allow_nil: true

  attr_accessor :comments

  after_create :send_project_proposed
  after_update :send_project_status_changed

  def Project.accepted_projects
    Project.where(status: "accepted")
  end

  def Project.rejected_projects
    Project.where(status: "rejected")
  end

  def Project.pending_projects
    Project.where(status: "pending")
  end

  def Project.current_pending_projects
    Project.where(status_published: false, quarter: Quarter.current_quarter)
  end

  def Project.current_accepted_projects
    Project.where(status: "accepted"). \
      joins(:quarter).where(quarters: { current: true })
  end

  def Project.quarter_accepted_projects(quarter)
    Project.where(status: "accepted"). \
      joins(:quarter).where(quarters: { id: quarter.id })
  end

  def advisor
    User.find(advisor_id)
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

  def in_current_quarter?
    self.quarter == Quarter.current_quarter
  end

  def accepted_submissions
    self.submissions.where(status: "accepted")
  end

  def cloneable?
    self.quarter != Quarter.current_quarter \
      and self.accepted_submissions.count == 0 \
      and !self.cloned?
  end

  def formatted_related_work
    self.related_work.present? ? self.related_work : "N/A"
  end

  def formatted_status_for_admins
    cap_stat = self.status.capitalize
    self.pending? ? cap_stat : "#{cap_stat} (flagged, not published)"
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
    errors.add(:user, "must be an advisor or admin") if \
      ( user.roles == ["student"] or user.roles == [] )
  end

  # Do we also need to check that this is a current project?
  def created_before_proposal_deadline
    errors.add_to_base("The proposal deadline has passed.") if \
      DateTime.now > Quarter.current_quarter.project_proposal_deadline
  end

  def accepted_before_submission_deadline
    message = "Cannot accept projects after the application deadline."
    errors.add_to_base(message) if self.status_changed? and \
      self.accepted? and \
      DateTime.now > Quarter.current_quarter.student_submission_deadline
  end

  def status_not_pending_when_published
    message = "Status must be accepted or rejected before it " \
              "can be published."
    errors.add_to_base(message) if self.pending? and self.status_published?
  end

end
