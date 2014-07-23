class Project < ActiveRecord::Base

  belongs_to :user, foreign_key: "advisor_id"
  has_many :submissions

  validates :name, presence: true, uniqueness: true
  validates :deadline, presence: true
  validates :description, presence: true,
    length: { minimum: 100, maximum: 1500 }
  validates :expected_deliverables, presence: true,
    length: { minimum: 100, maximum: 1500 }
  validates :prerequisites, presence: true,
    length: { minimum: 100, maximum: 1500 }

  delegate :email, to: :user, prefix: :advisor, allow_nil: true
  delegate :affiliation, to: :user, prefix: :advisor, allow_nil: true
  delegate :department, to: :user, prefix: :advisor, allow_nil: true

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

  private

  def send_project_proposed
    User.admins.each do |admin|
      Notifier.project_proposed(self, admin).deliver
    end
  end

  def send_project_status_changed
    Notifier.project_status_changed(self).deliver
  end

end
