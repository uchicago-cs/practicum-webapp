module ProjectsHelper

  def edit_change_type
    @project.draft? ? "create" : "edit"
  end

  def formatted_related_work(project)
    project.related_work.present? ? project.related_work : "N/A"
  end

  def format_cloned(project)
    project.cloned? ? "This project has been cloned." :
      "This project has not been cloned."
  end

  def projects_table
    @grouped_projects ? 'quarter_projects_tables' : 'projects_table'
  end

  def can_apply_to_project?
    q = @project.quarter
    (can? :apply_to, @project) and before_deadline?("student_submission", q)
  end

end
