class AddUserTypesToUsers < ActiveRecord::Migration
  def change
    User.reset_column_information
    reversible do |dir|
      dir.up { User.update_all type: "LdapUser" }
    end
  end
end
