class Evaluation < ActiveRecord::Base

  default_scope { order('created_at DESC') }

  belongs_to :submission, -> { where status: "accepted" },
             foreign_key: "submission_id"

  validates :advisor_id, presence: true
  validates :student_id, presence: true
  validates :project_id, presence: true
  validates :comments, presence: true,
            length: { minimum: 100, maximum: 1500 }
  validates_uniqueness_of :student_id, scope: :project_id

  validate :submission_status_is_sufficient, on: :create

  delegate :email, to: :student, prefix: :student, allow_nil: true
  delegate :email, to: :advisor, prefix: :advisor, allow_nil: true
  delegate :name, to: :project, prefix: :project, allow_nil: true
  delegate :accepted?, to: :submission, prefix: true, allow_nil: true
  delegate :status_approved?, to: :submission, prefix: true, allow_nil: true
  delegate :status_published?, to: :submission, prefix: true, allow_nil: true

  after_create :send_evaluation_submitted

  def student
    User.find(student_id)
  end

  def advisor
    User.find(advisor_id)
  end

  def project
    Project.find(project_id)
  end

  private

  def send_evaluation_submitted
    User.admins.each do |admin|
      Notifier.evaluation_submitted(self, admin).deliver
    end
  end

  def submission_status_is_sufficient
    message = "status must be approved, published, and accepted."
    errors.add(:submission, message) unless self.submission_accepted? and \
      self.submission_status_approved? and self.submission_status_published?
  end

end
