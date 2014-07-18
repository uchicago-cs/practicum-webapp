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

  def project_rejected(advisor, project)
    @advisor = advisor
    @project = project
    @to = @advisor.email
    @subject = "Your project \"#{@project.name}\""

    mail(to: @to, subject: @subject)
  end

  def project_status_changed(advisor, project, comment)
    @advisor = advisor
    @project = project
    @comment = comment
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

  def accept_student(student, project)
    @student = student
    @project = project
    @to = @student.email
    @subject = "You have been accepted to #{@project.name}"
    
    mail(to: @to, subject: @subject)
  end

  def reject_student(student, project)
    @student = student
    @project = project
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
