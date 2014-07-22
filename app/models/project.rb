class Project < ActiveRecord::Base

  belongs_to :user, foreign_key: "advisor_id"
  has_many :submissions
  # has_many :evaluations, foreign_key: "project_id"

  validates :name, presence: true, uniqueness: true
  validates :deadline, presence: true
  validates :description, presence: true,
    length: { minimum: 100, maximum: 1500 }
  validates :expected_deliverables, presence: true,
    length: { minimum: 100, maximum: 1500 }
  validates :prerequisites, presence: true,
    length: { minimum: 100, maximum: 1500 }

  delegate :email, to: :user, prefix: :advisor, allow_nil: true

  attr_accessor :comments

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

end
