class LocalUser < User

  devise :trackable, :database_authenticatable, :registerable,
         :recoverable

  validates :email, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  # Password confirmation is needed only on registration, i.e., for
  # local_users only.
  attr_accessor :password_confirmation
  validates :password_confirmation, presence: true
  validates :password, confirmation: true, presence: true,
                       length: { minimum: 8 }


end
