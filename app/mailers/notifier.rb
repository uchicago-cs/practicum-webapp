class Notifier < ActionMailer::Base
  default from: "practicum-notification@cs.uchicago.edu"
  layout 'mail'

  # Move admin deliveries here?

  def project_proposed(project)
    @advisor = project.advisor
    @project = project
    @bcc = User.admins.inject([]) { |bcc, admin| bcc << admin.email }
    @subject = "UChicago CS Masters Practicum: New project proposal"

    mail(bcc: @bcc, subject: @subject) do |format|
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
  def student_applied(submission)
    @advisor = submission.project.advisor
    @student = submission.student
    @project = submission.project
    @submission = submission
    @to = @advisor.email
    @subject = "UChicago CS Masters Practicum: New application"

    mail(to: @to, subject: @subject) do |format|
      format.text { render 'student_applied' }
      format.html { render 'student_applied' }
    end
  end

  def submission_status_updated(submission)
    @student = submission.student
    @advisor = submission.project.advisor
    @project = submission.project
    @submission = submission
    # The advisor presumably updated the status, so we inform the admins.
    # Also, advisors don't need to be informed about this.
    @bcc = User.admins.inject([]) { |bcc, admin| bcc << admin.email }
    @subject = "UChicago CS Masters Practicum: Application status update"

    mail(bcc: @bcc, subject: @subject) do |format|
      format.text { render 'submission_status_updated' }
      format.html { render 'submission_status_updated' }
    end
  end

  # Inform students about decision. If accepted, send to advisor as well.
  def submission_status_publish(submission)
    @student = submission.student
    @project = submission.project
    @submission = submission
    @status = submission.status
    @to = @student.email
    @cc = (@status == "accepted") ? @advisor.email : []
    @subject = "UChicago CS Masters Practicum: Application status update"

    mail(to: @to, cc: @cc, subject: @subject) do |format|
      format.text { render 'submission_status_publish' }
      format.html { render 'submission_status_publish' }
    end
  end

  def evaluation_submitted(evaluation)
    @advisor = evaluation.advisor
    @student = evaluation.student
    @evaluation = evaluation
    @bcc = User.admins.inject([]) { |bcc, admin| bcc << admin.email }
    @subject = "UChicago CS Masters Practicum: New evaluation"

    mail(bcc: @bcc, subject: @subject) do |format|
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
