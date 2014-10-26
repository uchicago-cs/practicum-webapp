class User < ActiveRecord::Base

  default_scope { order('users.created_at DESC') }
  scope :admins, -> { where(admin: true) }

  has_many :projects, foreign_key: "advisor_id", dependent: :destroy
  has_many :submissions, foreign_key: "student_id", dependent: :destroy

  validates :email, uniqueness: { case_sensitive: false }

  after_update :send_roles_changed

  # Current user, passed in from ApplicationController.
  attr_accessor :this_user
  attr_accessor :auth_attr

  def can_write_eval?

    # Quick fix to get the correct return value.
    createable_exists = false

    projects.each do |p|
      p.submissions.each do |s|
        createable_exists = true if s.active_eval_createable?
      end
    end

    EvaluationTemplate.current_active_available? and
      advisor? and projects.any? and createable_exists
  end

  def roles
    roles = []

    [:admin, :advisor, :student].each do |role|
      roles << role.to_s if self.send(role)
    end

    roles
  end

  def projects_applied_to
    Project.find(self.submissions.pluck(:project_id))
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

  def made_submission?(submission)
    submission.in? self.submissions
  end

  def accepted_projects
    self.projects.where(status: "accepted")
  end

  def pending_projects
    self.projects.where(status: "pending")
  end

  def projects_made_by_id
    Project.all.where(advisor_id: self.id).pluck(:id)
  end

  def evaluated_submission?(submission)
    Evaluation.where(advisor_id: self.id,
                     student_id: submission.student_id,
                     project_id: submission.project_id).exists?
  end

  def missing_proposal_info?
    self.affiliation.blank? or self.department.blank?
  end

  def current_projects
    self.projects.where(quarter: Quarter.current_quarter)
  end

  def send_roles_changed
    if this_user != self and
        (student_changed? or advisor_changed? or admin_changed?)
      Notifier.roles_changed(self).deliver
    end
  end

  # See this guide re: the two methods below:
  # https://github.com/plataformatec/devise/wiki/
  # How-To:-Require-admin-to-activate-account-before-sign_in

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    if !approved?
      :not_approved
    else
      super
    end
  end

end
