namespace :db do
  desc "Give users a default type:" +
    "\n- If their type is blank (nil or ''), make their type 'LdapUser'"

  task default_blank_user_types: :environment do
    update_user_types
  end
end

def update_user_types
  User.all.each do |user|
    user.update_column(:type, 'LdapUser') if user.type.blank?
  end
end
