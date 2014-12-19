module ApplicationHelper

  def q_link_to(txt, obj, path_type=obj.class.name.to_sym)
    # Link to a persisted project, submission, or evaluation, but the record's
    # quarter information is plugged into the path generator. Should not be used
    # when we don't need a quarter specified (e.g., for the global /projects
    # path) or when the record hasn't been created yet (for new records).

    # q_link_to("here", :project_path, @project) is the same as
    # link_to("here", project_path(@project, year: @project.quarter.year,
    #                              season: @project.quarter.season))

    y = obj.quarter.year
    s = obj.quarter.season
    path_type = (path_type.to_s + "_path").downcase.to_sym
    # TODO: generate proper path helper method; year: y and season: s are part
    # of a hash
    link_to(txt, path_type.to_proc.(obj, year: y, season: s)).html_safe
  end

  def projects_link_text
    if current_user and current_user.advisor? and !current_user.admin?
      "All Projects"
    else
      "Projects"
    end
  end

  def support_address
    "practicum-support@mailman.cs.uchicago.edu"
  end

  def project_proposal_navbar_link(quarter)
    if before_deadline?("project_proposal") or current_user.admin?
      content_tag(:li, link_to("Propose a project",
                               new_project_path(year: quarter.year,
                                                season: quarter.season)))
    else
      content_tag(:li, link_to("Propose a project", '#'), class: "disabled")
    end
  end

  def full_site_title
    "Practicum Program | Masters Program in Computer Science "\
    "| The University of Chicago"
  end

  def github_page
    "https://github.com/uchicago-cs/practicum-webapp"
  end

  def flash_class(flash_type)
    case flash_type
    when "notice"  then "info"
    when "success" then "success"
    when "error"   then "danger"
    when "alert"   then "warning"
    else               flash_type
    end
  end

  # Determine table row class for admins.
  def row_class(status)
    { "accepted" => "success", "rejected" => "danger", "pending" => "",
      "draft"    => "" }[status]
  end

  def formatted_current_quarter
    quarter = Quarter.current_quarter
    if quarter
      [quarter.season.capitalize, quarter.year].join(" ")
    else
      "this quarter"
    end
  end

  def formatted_quarter_by_params
    if params[:year] and params[:season]
      # Specific quarter (find_by?)
      quarter = Quarter.where(year: params[:year], season: params[:season]).take
      if quarter
        [quarter.season.capitalize, quarter.year].join(" ")
      else
        "this quarter" # Dummy text -- should never be returned
      end
    else
      # Global page
      "Recent"
    end

  end

  # Formatted deadlines (not the DateTime objects, which
  # @quarter.deadline(deadline) returns).
  def formatted_deadline(deadline)
    Quarter.current_quarter.deadline(deadline).
      strftime("%I:%M %p on %D (%A, %B %d, %Y)")
  end

  def before_deadline?(deadline)
    DateTime.now <= Quarter.current_quarter.deadline(deadline)
  end

  def formatted_project_status(project)
    if project.pending? or project.rejected? or project.status_published? or
        project.draft?
      project.status.capitalize
    elsif !project.status_published?
      "#{project.status.capitalize} (flagged, not published)"
    end
  end

  def formatted_submission_count(project)
    if project.accepted? and project.status_published?
      project.submissions.count
    end
  end

end
