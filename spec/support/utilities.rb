require 'spec_helper'
include Warden::Test::Helpers
include ApplicationHelper

# Make the user signed in without signing them in (i.e., bypass LDAP auth).
def ldap_sign_in(user)
  login_as(user, scope: :ldap_user)
end
