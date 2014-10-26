class LocalUser < User

  devise :trackable, :validatable, :database_authenticatable, :registerable,
         :recoverable

  # Password confirmation is needed only on registration, i.e., for
  # local_users only.
  attr_accessor :password_confirmation
  validates :password, confirmation: true
  validates :password_confirmation, presence: true

end
