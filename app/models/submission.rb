class Submission < ActiveRecord::Base

  belongs_to :user
  belongs_to :project

  validates :information, presence: true,
                          length: { minimum: 100, maximum: 1500 }
  validates :student_id, presence: true

  delegate :name, to: :project, prefix: true
  # Replaces the following:
  # def project_name
  #   project.name
  # end

  # Can delegate this method, as well:
  def student_email
    user.try(:email)
  end

end
