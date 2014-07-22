class Evaluation < ActiveRecord::Base

  #belongs_to :student, class: "User", foreign_key: "student_id"
  belongs_to :advisor, -> { where advisor: true },
             class_name: "User", foreign_key: "advisor_id"
  #belongs_to :project, foreign_key: "project_id"

  validates :advisor_id, presence: true
  validates :student_id, presence: true
  validates :project_id, presence: true
  validates :comments, presence: true,
            length: { minimum: 100, maximum: 1500 }

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
