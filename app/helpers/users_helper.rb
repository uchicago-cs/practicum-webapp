module UsersHelper

  def formatted_email(user)
    user.cnet.present? ? "#{user.cnet}@uchicago.edu" : user.email
    # We could also automatically create a user's e-mail if they've
    # authenticated with LDAP. Then this function would be unnecessary.
  end

  # Write a similar method for submission notes?
  def project_notes(project)
    if project.pending?
      "You may edit this proposal " +
        link_to("here", edit_project_path(project.id)) + "."
    elsif project.accepted?
      "You may view students' applications to this project " +
        link_to("here", project_submissions_path(project.id)) + "."
    elsif project.draft?
      "You may edit and / or submit this proposal draft " +
        link_to("here", edit_project_path(project.id)) + "."
    else
      ""
    end.html_safe
  end

  def user_role_warning
    "If you update this user's roles (and you are not this user), an e-mail "\
    "will be sent to them."
  end

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
