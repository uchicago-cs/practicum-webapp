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

  def relevant_quarters
    if admin?
      # See all active quarters.
      Quarter.active_quarters.to_a

    elsif advisor?
      # See 1. quarters for which the proposal period is open, and
      # 2. quarters with passed proposal periods but for which the advisor
      # has submitted a proposal and which are not yet over.
      qs = Quarter.open_for_proposals.to_set

      # Loop through this user's projects. For each project, check if the
      # quarter is active. If so, add it to the set.
      projects.each { |p| qs.add(p.quarter) if p.quarter.current? }

      qs.to_a

    elsif student?
      # Same rule as for advisors, except that it applies to submissions.
      qs = Quarter.open_for_submissions.to_set

      submissions.each { |s| qs.add(s.quarter) if s.quarter.current? }

      qs.to_a

    else # The user is not logged in.
      Quarter.active_quarters.to_a
    end
  end

  def students_and_submissions_in_quarter(quarter)
    # Returns a hash of students (keys) and applications (values) the current
    # advisor is managing in the given quarter.
    students = Hash.new

    projects.where(quarter: quarter).each do |p|
      p.submissions.each do |s|
        if s.accepted? and s.status_approved? and s.status_published?
          students[s.student] = s
        end
      end
    end

    students
  end

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

  def completed_active_evaluation?(submission)
    e = Evaluation.where(advisor_id: self.id,
                         student_id: submission.student_id,
                         project_id: submission.project_id).take
    # Note that e should be unique
    e.present? and e.evaluation_template == EvaluationTemplate.current_active
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

end
