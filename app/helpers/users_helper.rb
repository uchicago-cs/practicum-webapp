module UsersHelper

  def display_name(user)
    if user.first_name.present? and user.last_name.present?
      "#{user.first_name} #{user.last_name}"
    else
      user.cnet
    end
  end

  def formatted_roles(user)
    user.roles.join(", ")
  end

  def formatted_info(user)
    info = display_name(user)
    info << ", #{user.department}"  if user.department.present?
    info << ", #{user.affiliation}" if user.affiliation.present?
    info
  end

end
