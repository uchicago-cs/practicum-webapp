class User < ActiveRecord::Base

  has_many :projects, foreign_key: "advisor_id"
  has_many :submissions, foreign_key: "student_id"

  ROLES = [:admin, :advisor, :student]

  # Devise modules.
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable
end


