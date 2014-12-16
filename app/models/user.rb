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
      qs = []

      Quarter.all.each do |q|
        if q.start_date <= DateTime.now and DateTime.now <= q.end_date
          qs << q
        end
      end

      qs

    elsif advisor?
      # See 1. quarters for which the proposal period is open, and
      # 2. quarters with passed proposal periods but for which the advisor
      # has submitted a proposal and which are not yet over.
      qs = Quarter.open_for_proposals.to_set

      # loop through projects. for each project, check if the quarter is active.
      # if so, add it to the set.
      projects.each { |p| qs.add(p.quarter) if p.quarter.current? }

      qs.to_a

    elsif student?
      # Returns a list of all the quarters in which the user created objects
      # (proposals, applications, or evaluations).
      qs = Set.new []
      objects = projects + submissions + Evaluation.where(advisor_id: self.id)

      objects.each do |o|
        if o.instance_of? Evaluation
          # The quarter of an evaluation is the quarter in which its project
          # was made.
          qs.add(o.project.quarter)
        else
          qs.add(o.quarter)
        end
      end

      qs.to_a
    end
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

end
