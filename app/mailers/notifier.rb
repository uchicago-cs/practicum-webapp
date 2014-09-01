class Notifier < ActionMailer::Base
  default from: "practicum-notification@cs.uchicago.edu"
  layout 'mail'

  # Move admin deliveries here?

  def project_proposed(project, admin)
    @advisor = project.advisor
    @project = project
    @admin = admin
    @to = @admin.email
    @subject = "UChicago CS Masters Practicum: New project proposal"

    mail(to: @to, subject: @subject) do |format|
      format.text { render 'project_proposed' }
      format.html { render 'project_proposed' }
    end
  end

  def project_status_changed(project)
    @advisor = project.advisor
    @project = project
    @comments = project.comments
    @status = project.status
    @to = @advisor.email
    @subject = "UChicago CS Masters Practicum: Project status update"

    mail(to: @to, subject: @subject) do |format|
      format.text { render 'project_status_changed' }
      format.html { render 'project_status_changed' }
    end
  end

  # Only for accepted projects
  def project_status_published_accepted(project)
    @advisor = project.advisor
    @project = project
    @status = project.status
    @to = @advisor.email
    @subject = "UChicago CS Masters Practicum: Project status update"

    mail(to: @to, subject: @subject) do |format|
      format.text { render 'project_status_published_accepted' }
      format.html { render 'project_status_published_accepted' }
    end
  end

  # Should admins be notified about this?
  def student_applied(advisor, student, project=nil, submission=nil)
    @advisor = advisor
    @student = student
    @project = project
    @submission = submission
    @to = @advisor.email
    @subject = "UChicago CS Masters Practicum: New application"

    mail(to: @to, subject: @subject) do |format|
      format.text { render 'student_applied' }
      format.html { render 'student_applied' }
    end
  end

  # Status changed
  def submission_status_update(admin, advisor, submission)
    @student = submission.student
    @admin = admin
    @advisor = advsior
    @project = submission.project
    @submission = submission
    @to = @admin.email
    @subject = "UChicago CS Masters Practicum: Application status update"

    mail(to: @to, subject: @subject) do |format|
      format.text { render 'submission_status_update' }
      format.html { render 'submission_status_update' }
    end
  end

  # Inform students about decision. If accepted, send to advisor as well.
  def submission_status_publish(submission)
    @student = submission.student
    @project = submission.project
    @submission = submission
    @to = @student.email
    @subject = "UChicago CS Masters Practicum: Application status update"

    mail(to: @to, subject: @subject) do |format|
      format.text { render 'submission_status_publish' }
      format.html { render 'submission_status_publish' }
    end
  end

  # ---------------------------------------------------------------- #
  # ---------------------------------------------------------------- #

  # Status published: also send to advisor
  def accept_student(submission)
    @student = submission.student
    @project = submission.project
    @to = @student.email
    @subject = "UChicago CS Masters Practicum: Application status update"

    mail(to: @to, subject: @subject)
  end

  # Status published
  def reject_student(submission)
    @student = submission.student
    @project = submission.project
    @to = @student.email
    @subject = "UChicago CS Masters Practicum: Application status update"

    mail(to: @to, subject: @subject)
  end

  # ---------------------------------------------------------------- #
  # ---------------------------------------------------------------- #

  def evaluation_submitted(evaluation, admin)
    @advisor = evaluation.advisor
    @admin = admin
    @student = nil
    @evaluation = evaluation
    @to = @admin.email
    @subject = "UChicago CS Masters Practicum: New evaluation"

    mail(to: @to, subject: @subject) do |format|
      format.text { render 'evaluation_submitted' }
      format.html { render 'evaluation_submitted' }
    end
  end

  def request_for_advisor_access(user, admin)
    @user = user
    @admin = admin
    @to = @admin.email
    @subject = "UChicago CS Masters Practicum: Advisor status request"

    mail(to: @to, subject: @subject) do |format|
      format.text { render 'request_for_advisor_access' }
      format.html { render 'request_for_advisor_access' }
    end
  end

end
