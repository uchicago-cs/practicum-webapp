class User < ActiveRecord::Base

  has_many :projects, foreign_key: "advisor_id", dependent: :destroy
  has_many :submissions, foreign_key: "student_id", dependent: :destroy

  ROLES = [:admin, :advisor, :student]

  devise :database_authenticatable, :registerable,
  :rememberable, :trackable, :validatable

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
    self.submissions.pluck(:project_id)
  end

  def already_applied_to_projects?
    self.submissions.count > 0
  end

  def already_applied_to_project?(project_id)
    project_id.in?(self.projects_applied_to)
  end

  def approved_projects
#    if self.advisor?
      self.projects.where(approved: true)
#    end
  end

  def unapproved_projects
#    if self.advisor?
      self.projects.where(approved: false)
#    end
  end

end


