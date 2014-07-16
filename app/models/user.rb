class User < ActiveRecord::Base

  has_many :projects, foreign_key: "advisor_id", dependent: :destroy
  has_many :submissions, foreign_key: "student_id", dependent: :destroy

  devise :database_authenticatable, :registerable,
         :rememberable, :trackable, :validatable

  def User.admins
    User.where(admin: true)
  end

  def roles
    roles = []

    if self.admin?
      roles << "admin"
    end

    if self.advisor?
      roles << "advisor"
    end

    if self.student?
      roles << "student"
    end

    # [:student, :advisor, :admin].each do |role|
    #   if self.send(role)
    #     roles << role.to_s
    #   end
    # end
    
    roles
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

  def accepted_projects
    self.projects.where(status: "accepted")
  end

  def pending_projects
    self.projects.where(status: "pending")
  end

end
