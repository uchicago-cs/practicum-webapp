class Submission < ActiveRecord::Base

  belongs_to :user, foreign_key: "student_id"
  belongs_to :project

  validates :information, presence: true,
                          length: { minimum: 100, maximum: 1500 }
  validates :student_id, presence: true

  delegate :name, to: :project, prefix: true
  delegate :email, to: :user, prefix: :student

end
