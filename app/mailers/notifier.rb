class Notifier < ActionMailer::Base
  default from: "do-not-reply@cs.uchicago.edu"

  def project_proposed(project, admin)
    @advisor = project.advisor
    @project = project
    @admin = admin
    @to = @admin.email
    @subject = "A new project has been proposed"

    mail(to: @to, subject: @subject)
  end

  def project_status_changed(project)
    @advisor = project.advisor
    @project = project
    @comments = project.comments
    @status = project.status
    @to = @advisor.email
    @subject = "Your project status has been updated"

    mail(to: @to, subject: @subject)
  end

  def student_applied(advisor, student)
    @advisor = advisor
    @student = student
    @to = @advisor.email
    @subject = "A student has applied to your project"

    mail(to: @to, subject: @subject)
  end

  def accept_student(submission)
    @student = submission.student
    @project = submission.project
    @to = @student.email
    @subject = "You have been accepted to #{@project.name}"

    mail(to: @to, subject: @subject)
  end

  def reject_student(submission)
    @student = submission.student
    @project = submission.project
    @to = @student.email
    @subject = "Your application to #{@project.name}"

    mail(to: @to, subject: @subject)
  end

  def evaluation_submitted(advisor, admin) #, evaluation)
    @advisor = advisor
    @admin = admin
    @to = @admin.email
    @subject = "#{@advisor.email} has submitted a new evaluation"

    mail(to: @to, subject: @subject)
  end

end
