class Notifier < ActionMailer::Base
  default from: "do-not-reply@cs.uchicago.edu"

  def project_proposed(advisor, project, admin)
    @advisor = advisor
    @project = project
    @admin = admin
    @to = @admin.email
    @subject = "A new project has been proposed"

    mail(to: @to, subject: @subject)
  end

  def project_accepted(advisor, project)
    @advisor = advisor
    @project = project
    @to = @advisor.email
    @subject = "Your project \"#{@project.name}\" has been approved"

    mail(to: @to, subject: @subject)
  end

  def project_needs_edits(advisor, project)
    @advisor = advisor
    @project = project
    @to = @advisor.email
    @subject = "Your project \"#{@project.name}\" requires attention"

    mail(to: @to, subject: @subject)
  end

  def student_applied(advisor, student)
    @advisor = advisor
    @student = student
    @to = @advisor.email
    @subject = "A student has applied to your project"
    
    mail(to: @to, subject: @subject)
  end

  def accept_student(student, project)
    @student = student
    @project = project
    @to = @student.email
    @subject = "You have been accepted to #{@project.name}"
    
    mail(to: @to, subject: @subject)
  end

end
