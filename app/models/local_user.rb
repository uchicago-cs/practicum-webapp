class LocalUser < User

  devise :trackable, :validatable, :database_authenticatable, :registerable,
         :recoverable

end
