class Project < ActiveRecord::Base

  belongs_to :user, foreign_key: "advisor_id"
  has_many :submissions

  validates :name, presence: true, uniqueness: true
  validates :deadline, presence: true
  validates :description, presence: true,
                         length: { minimum: 100, maximum: 1500 }

  delegate :email, to: :user, prefix: :advisor, allow_nil: true

  def Project.approved_projects
    Project.where(approved: true)
  end

  def Project.unapproved_projects
    Project.where(approved: false)
  end

  def advisor
    User.find(advisor_id)
    # Not ideal
  end

  def status
    if self.approved?
      "approved"
    else
      "unapproved"
    end
  end

end
