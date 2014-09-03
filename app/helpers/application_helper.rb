module ApplicationHelper

  def project_proposal_navbar_link
    if before_deadline?("project_proposal")
      content_tag(:li, link_to("Propose a project", new_project_path))
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
    {"accepted" => "success", "rejected" => "danger", "pending" => ""}[status]
  end

  def formatted_current_quarter
    quarter = Quarter.current_quarter
    if quarter
      [quarter.season.capitalize, quarter.year].join(" ")
    else
      "this quarter"
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
    if project.pending? or project.rejected? or project.status_published?
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
