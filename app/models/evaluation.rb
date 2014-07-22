class Evaluation < ActiveRecord::Base


  belongs_to :advisor, -> { where advisor: true },
             class_name: "User", foreign_key: "advisor_id"

  validates :advisor_id, presence: true
  validates :student_id, presence: true
  validates :project_id, presence: true
  validates :comments, presence: true,
            length: { minimum: 100, maximum: 1500 }
  validates_uniqueness_of :student_id, scope: :project_id

  def student
    User.find(student_id)
  end

  def advisor
    User.find(advisor_id)
  end

  def project
    Project.find(project_id)
  end

end
