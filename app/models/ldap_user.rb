class LdapUser < User

  devise :trackable, :validatable, :ldap_authenticatable,
  authentication_keys: [:cnet]

  before_validation :get_ldap_info
  after_create :approve_account

  # Fix routes for STI subclass (LocalUser) of User so that we can call
  # current_user and generate a path in the view, rather than calling
  # user_path(current_user).
  def self.model_name
    User.model_name
  end

  def get_ldap_info
    if Devise::LDAP::Adapter.get_ldap_param(self.cnet, 'uid')
      self.email = Devise::LDAP::Adapter.
        get_ldap_param(self.cnet, "mail").first

      # For CNet users who do not have a givenName (?) or a sn
      ldap_first_name = (Devise::LDAP::Adapter.get_ldap_param(self.cnet,
                                        "givenName") rescue nil)
      self.first_name = (ldap_first_name ? ldap_first_name.first : "")

      ldap_surname = (Devise::LDAP::Adapter.get_ldap_param(self.cnet,
                                                           "sn") rescue nil)
      self.last_name = (ldap_surname ? ldap_surname.first : "")

      self.student = true
    end
  end

  def approve_account
    self.update_attributes(approved: true)
  end

end
