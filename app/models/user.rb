class User < ActiveRecord::Base

  has_many :projects, foreign_key: "advisor_id", dependent: :destroy
  has_many :submissions, foreign_key: "student_id", dependent: :destroy

  ROLES = [:admin, :advisor, :student]

  # Devise modules.
  devise :database_authenticatable, :registerable,
  :rememberable, :trackable, :validatable#, :recoverable

  # Validations? Already taken care of by Devise?

  def admin?
    self.role == "admin"
  end

  def advisor?
    self.role == "advisor"
  end

  def student?
    self.role == "student"
  end

end


