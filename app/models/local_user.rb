class LocalUser < User

  devise :trackable, :database_authenticatable, :registerable,
         :recoverable

  validates :email, presence: true, on: :create
  validates :first_name, presence: true, on: :create
  validates :last_name, presence: true, on: :create
  validates :affiliation, presence: true, on: :create
  validates :department, presence: true, on: :create

  # Password confirmation is needed only on registration, i.e., for
  # local_users only.
  attr_accessor :password_confirmation
  validates :password_confirmation, presence: true, on: :create
  validates :password, confirmation: true, presence: true,
                       length: { minimum: 8 }, on: :create

  after_create :send_admin_email
  after_update :send_account_approved

  # Fix routes for STI subclass (LocalUser) of User so that we can call
  # current_user and generate a path in the view, rather than calling
  # user_path(current_user).
  def self.model_name
    User.model_name
  end

  def send_admin_email
    User.admins.each do |a|
      Notifier.local_user_awaiting_approval(self, a).deliver
    end
  end

  # See this link re: the two methods below:
  # https://github.com/plataformatec/devise/wiki/
  # How-To:-Require-admin-to-activate-account-before-sign_in

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    if !approved?
      :not_approved
    else
      super
    end
  end

  private

  def send_account_approved
    if approved_changed? and approved?
      Notifier.account_approved(self).deliver
    end
  end

end
