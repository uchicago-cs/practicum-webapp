class User < ActiveRecord::Base

  has_many :projects, foreign_key: "advisor_id", dependent: :destroy
  has_many :submissions, foreign_key: "student_id", dependent: :destroy

  ROLES = [:admin, :advisor, :student]

  # Devise modules.
  devise :database_authenticatable, :registerable,
  :rememberable, :trackable, :validatable#, :recoverable

  # Validations? Already taken care of by Devise?

  def admin?
    self.role == "admin"
  end

  def advisor?
    self.role == "advisor"
  end

  def student?
    self.role == "student"
  end

  def projects_applied_to
    # Returns an array of the project_id's of the projects this
    # student has applied to. If user is not a student, returns 0.
    if self.student?
      self.submissions.pluck(:project_id)
    else
      0
    end
  end

  def already_applied_to_project?(project_id)
    project_id.in?(self.projects_applied_to)
  end

  def approved_projects
    if self.advisor?
      self.projects.where(approved: true)
    end
  end

  def unapproved_projects
    if self.advisor?
      self.projects.where(approved: false)
    end
  end

end


