module ApplicationHelper

  # TODO: DRY these quarter (q_) methods? (Also see /spec/support/utilities.rb)
  def q_link_to(txt, obj, path_type=obj.class.name.to_sym, opts={})
    # Link to a persisted project, submission, or evaluation, but the record's
    # quarter information is plugged into the path generator. Should not be used
    # when we don't need a quarter specified (e.g., for the global /projects
    # path) or when the record hasn't been created yet (for new records).

    # q_link_to("here", :project_path, @project) is the same as
    # link_to("here", project_path(@project, year: @project.quarter.year,
    #                              season: @project.quarter.season))

    # [Alternatively, try `polymorphic_path`?]

    y = obj.quarter.year
    s = obj.quarter.season
    # If path_type ends with _url, change nothing; otherwise, default to _path.
    # A path_type of :project will generate project_path, and a path_type
    # of :project_url will generate project_url.
    suffix = /_url$/.match(path_type.to_s) ? "" : "_path"
    path_type = (path_type.to_s + suffix).downcase
    link_to(txt, send(path_type, obj, {year: y, season: s}), opts).html_safe
  end

  # See /spec/support/utilities.rb
  def q_path(obj, path_type=obj.class.name.to_sym)
    y = obj.quarter.year
    s = obj.quarter.season
    path_type = (path_type.to_s + "_path").downcase
    h = { year: y, season: s }
    send(path_type, obj, h)
  end

  def q_url(obj, url_type=obj.class.name.to_sym, opts={})
    # Similar to q_link_to but for url helpers, and does not wrap the link in
    # a link_to.

    y = obj.quarter.year
    s = obj.quarter.season
    url_type = (url_type.to_s + "_url").downcase
    send(url_type, obj, {year: y, season: s})
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
    "Practicum Program | Masters Program in Computer Science " +
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
    else                flash_type
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
      # Specific quarter
      quarter = Quarter.find_by(year: params[:year], season: params[:season])
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
