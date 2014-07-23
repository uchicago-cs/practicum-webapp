class Evaluation < ActiveRecord::Base

  belongs_to :advisor, -> { where advisor: true },
             class_name: "User", foreign_key: "advisor_id"

  validates :advisor_id, presence: true
  validates :student_id, presence: true
  validates :project_id, presence: true
  validates :comments, presence: true,
            length: { minimum: 100, maximum: 1500 }
  validates_uniqueness_of :student_id, scope: :project_id

  delegate :email, to: :student, prefix: :student, allow_nil: true
  delegate :email, to: :advisor, prefix: :advisor, allow_nil: true
  delegate :name, to: :project, prefix: :project, allow_nil: true

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

end
