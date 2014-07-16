class User < ActiveRecord::Base

  has_many :projects, foreign_key: "advisor_id", dependent: :destroy
  has_many :submissions, foreign_key: "student_id", dependent: :destroy

  devise :database_authenticatable, :registerable,
  :rememberable, :trackable, :validatable

  def User.admins
    User.where(role: "admin")
  end

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
    Project.find(self.submissions.pluck(:project_id))
    # Not ideal...
  end

  def applied_to_projects?
    self.submissions.count > 0
  end

  def applied_to_project?(project)
    project.in?(self.projects_applied_to)
  end

  def made_project?(project)
    project.in?(self.projects)
  end

  def approved_projects
    self.projects.where(approved: true)
  end

  def unapproved_projects
    self.projects.where(approved: false)
  end

end
