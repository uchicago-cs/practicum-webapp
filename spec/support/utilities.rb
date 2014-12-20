require 'spec_helper'
include Warden::Test::Helpers

# Make the user signed in without signing them in (i.e., bypass LDAP auth).
def ldap_sign_in(user)
  login_as(user, scope: :ldap_user)
end

# See application_helper.rb
def q_path(obj, path_type=obj.class.name.to_sym)
  y = obj.quarter.year
  s = obj.quarter.season
  obj_id = (obj.class.name + "_id").downcase.to_sym
  path_type = (path_type.to_s + "_path").downcase
  h = { year: y, season: s }
  send(path_type, obj, h)
end
