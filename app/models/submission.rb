class Submission < ActiveRecord::Base

  belongs_to :user
  belongs_to :project

  def student_email
    User.find(self.student_id).email
  end

  def project_name
    Project.find(self.project_id).name
  end

end
