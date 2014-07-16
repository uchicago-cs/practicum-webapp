class Notifier < ActionMailer::Base
  default from: "do-not-reply@cs.uchicago.edu"

  def student_applied(advisor)
    @advisor = advisor

    mail(to: @advisor.email)
  end

  def accept_student(student)
    @student = student
    
    mail(to: @student.email)
  end

end
