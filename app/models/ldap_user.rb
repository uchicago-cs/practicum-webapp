class LdapUser < User

  devise :trackable, :validatable, :ldap_authenticatable,
  authentication_keys: [:cnet]

  before_validation :get_ldap_info

  def get_ldap_info
    if Devise::LDAP::Adapter.get_ldap_param(self.cnet, 'uid')
      self.email = Devise::LDAP::Adapter.
        get_ldap_param(self.cnet, "mail").first

      self.first_name = (Devise::LDAP::Adapter.
                         get_ldap_param(self.cnet,
                                        "givenName") rescue nil).first

      self.last_name = (Devise::LDAP::Adapter.
                        get_ldap_param(self.cnet, "sn") rescue nil).first

      self.student = true
    end
  end

end
