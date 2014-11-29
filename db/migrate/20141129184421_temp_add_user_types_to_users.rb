class TempAddUserTypesToUsers < ActiveRecord::Migration
  def change
    User.reset_column_information
    reversible do |dir|
      dir.up {
        User.all.each do |user|
          user.update_column(:type, "LdapUser") if user.type.empty?
        end
      }
    end
  end
end
